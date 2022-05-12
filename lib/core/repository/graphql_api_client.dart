import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' hide NetworkException, ServerException;
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarthome/app/settings/settings_controller.dart';
import 'package:smarthome/core/graphql/mutations/mutations.dart';
import 'package:smarthome/utils/exceptions.dart';

class GraphQLApiClient {
  static final Logger _log = Logger('GraphQLApiClient');
  static Map<String, String> headers = {};
  static GraphQLClient? _client;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final SettingsController settingsController;

  GraphQLApiClient(
    this.settingsController,
  );

  GraphQLClient? get client => _client;

  Future<String?> get token async {
    final prefs = await _prefs;
    return prefs.getString('token');
  }

  /// 登录
  Future<bool> authenticate(String username, String password) async {
    final loginOptions = MutationOptions(
      document: gql(tokenAuth),
      variables: {
        'input': {
          'username': username,
          'password': password,
        }
      },
    );
    final results = await _client!.mutate(loginOptions);
    if (results.hasException) {
      if (results.exception!.linkException != null) {
        throw const NetworkException('网络异常，请稍后再试');
      }
      return false;
    } else {
      String token = results.data!['tokenAuth']['token'];
      String refreshToken = results.data!['tokenAuth']['refreshToken'];
      await _setToken(token);
      await _setRefreshToken(refreshToken);
      return true;
    }
  }

  /// 初始化 GraphQL 客户端
  void initailize(String url) {
    final authLink = AuthLink(getToken: () async => 'JWT ${await token}');
    final httpLink = HttpLink(
      url,
      defaultHeaders: headers,
    );
    final tokenErrorLink = ErrorLink(onGraphQLError: _handleTokenError);
    final link = tokenErrorLink.split((request) {
      final definition = request.operation.document.definitions.first;
      if (definition.runtimeType == OperationDefinitionNode) {
        final operationName =
            (definition as OperationDefinitionNode).name!.value;
        if (operationName == 'tokenAuth' || operationName == 'refreshToken') {
          return false;
        }
      }
      return true;
    }, authLink.concat(httpLink), httpLink);

    _client = GraphQLClient(
      cache: GraphQLCache(),
      link: link,
    );
    _log.fine('GraphQLClient initailized with url $url');
  }

  /// 加载配置，比如用户代理
  /// 这些需要在最开始就加载，因为后面的操作需要用到
  Future<void> loadSettings() async {
    // 用户代理设置为当前手机
    // 暂时只支持 Android
    // SmartHome/0.6.1 (Linux; Android 10; Mi-4c Build/QQ3A.200805.001)
    if (!kIsWeb && Platform.isAndroid) {
      try {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;
        final packageInfo = await PackageInfo.fromPlatform();
        headers['User-Agent'] =
            'SmartHome/${packageInfo.version} (Linux; Android ${androidInfo.version.release}; ${androidInfo.model} Build/${androidInfo.id})';
      } catch (exception, stackTrace) {
        await Sentry.captureException(
          exception,
          stackTrace: stackTrace,
        );
        _log.severe('设置 User-Agent 失败 (${exception.toString()})');
      }
    }
  }

  /// 更改
  Future<QueryResult> mutate(MutationOptions options) async {
    final results = await _client!.mutate(options);
    if (results.hasException) {
      _handleException(results.exception!);
    }
    return results;
  }

  /// 查询
  Future<QueryResult> query(QueryOptions options) async {
    final results = await _client!.query(options);
    if (results.hasException) {
      _handleException(results.exception!);
    }
    return results;
  }

  void _handleException(OperationException exception) {
    for (var error in exception.graphqlErrors) {
      if (error.message.toLowerCase().contains('refresh token')) {
        settingsController.updateLoginUser(null);
        throw const AuthenticationException('认证过期，请重新登录');
      }
      _log.warning(error.toString());
      throw ServerException(error.message);
    }
    if (exception.linkException != null) {
      _log.severe(exception.linkException.toString());
      throw const NetworkException('网络异常，请稍后再试');
    }
  }

  /// 处理令牌相关的问题
  Stream<Response> _handleTokenError(
      Request request, forward, Response response) async* {
    final message = response.errors!.first.message.toLowerCase();
    if ([
      'signature has expired',
      'error decoding signature',
    ].contains(message)) {
      // 如果访问令牌失效，则自动刷新
      final error = await _refreshToken();
      if (error.isEmpty) {
        yield* forward(request);
      } else {
        yield Response(
          data: response.data,
          errors: error,
          context: response.context,
          response: response.response,
        );
      }
    } else {
      yield response;
    }
  }

  /// 刷新令牌
  Future<List<GraphQLError>> _refreshToken() async {
    final prefs = await _prefs;
    _log.fine('refreshing token');
    final refreshToken = prefs.getString('refreshToken');
    final options = MutationOptions(
      document: gql(refreshTokenMutation),
      variables: {
        'input': {
          'refreshToken': refreshToken,
        }
      },
    );
    final results = await _client!.mutate(options);

    // 如果刷新令牌出错，则返回错误
    final exception = results.exception;
    if (exception != null && exception.graphqlErrors.isNotEmpty) {
      return results.exception!.graphqlErrors;
    } else {
      String token = results.data!['refreshToken']['token'];
      await _setToken(token);
      _log.fine('token refreshed');
      return [];
    }
  }

  Future _setRefreshToken(String refreshToken) async {
    final prefs = await _prefs;
    await prefs.setString('refreshToken', refreshToken);
  }

  Future _setToken(String token) async {
    final prefs = await _prefs;
    await prefs.setString('token', token);
  }
}
