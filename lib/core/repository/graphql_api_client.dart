import 'dart:async';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/foundation.dart';
import 'package:graphql/client.dart' hide NetworkException, ServerException;
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gql_exec/gql_exec.dart';
import 'package:gql/ast.dart';
import 'package:smarthome/core/graphql/mutations/mutations.dart';
import 'package:smarthome/utils/exceptions.dart';

class GraphQLApiClient {
  static final Logger _log = Logger('GraphQLApiClient');
  static GraphQLClient? _client;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  // ignore: close_sinks
  final _loginStatusControler = StreamController<bool>();

  GraphQLApiClient();

  GraphQLClient? get client => _client;

  /// 是否登录
  /// 通过判断是否拥有刷新令牌
  Future<bool> get isLogin async {
    final SharedPreferences prefs = await _prefs;
    String? token = prefs.getString('refreshToken');
    if (token == null || token == '') {
      return false;
    } else {
      return true;
    }
  }

  Stream<bool> get loginStatus => _loginStatusControler.stream;

  Future<String?> get token async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString('token');
  }

  /// 登录
  Future<bool> authenticate(String username, String password) async {
    MutationOptions loginOptions = MutationOptions(
      document: gql(tokenAuth),
      variables: {
        'input': {
          'username': username,
          'password': password,
        }
      },
    );
    QueryResult results = await _client!.mutate(loginOptions);
    if (results.hasException) {
      if (results.exception!.linkException != null) {
        throw NetworkException('网络异常，请稍后再试');
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
  Future<bool> initailize(String url) async {
    try {
      final AuthLink _authLink =
          AuthLink(getToken: () async => 'JWT ${await token}');
      // 用户代理设置为当前手机
      // 暂时只支持 Android
      // SmartHome/0.6.1 (Linux; Android 10; Mi-4c Build/QQ3A.200805.001)
      Map<String, String> headers = {};
      if (!kIsWeb && Platform.isAndroid) {
        try {
          final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
          AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
          final PackageInfo packageInfo = await PackageInfo.fromPlatform();
          headers['User-Agent'] =
              'SmartHome/${packageInfo.version} (Linux; Android ${androidInfo.version.release}; ${androidInfo.model} Build/${androidInfo.id})';
        } catch (e) {
          _log.severe('设置 User-Agent 失败 (${e.toString()})');
        }
      }
      final HttpLink _httpLink = HttpLink(
        url,
        defaultHeaders: headers,
      );
      final ErrorLink _tokenErrorLink =
          ErrorLink(onGraphQLError: _handleTokenError);
      final Link _link = _tokenErrorLink.split((request) {
        final DefinitionNode definition =
            request.operation.document.definitions.first;
        if (definition.runtimeType == OperationDefinitionNode) {
          final String operationName =
              (definition as OperationDefinitionNode).name!.value;
          if (operationName == 'tokenAuth' || operationName == 'refreshToken') {
            return false;
          }
        }
        return true;
      }, _authLink.concat(_httpLink), _httpLink);

      _client = GraphQLClient(
        cache: GraphQLCache(),
        link: _link,
      );
      _log.fine('GraphQLClient initailized with url $url');
      return true;
    } on MyException catch (e) {
      _log.severe(e);
      return false;
    }
  }

  /// 登出
  Future logout() async {
    final SharedPreferences prefs = await _prefs;
    await prefs.remove('token');
    await prefs.remove('refreshToken');
    await prefs.remove('loginUser');
    _log.fine('clear refresh token');
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
        // 通知认证 BLoC 登陆失败
        _loginStatusControler.sink.add(false);
        throw AuthenticationException('认证过期，请重新登录');
      }
      _log.warning(error.toString());
      throw ServerException(error.message);
    }
    if (exception.linkException != null) {
      _log.severe(exception.linkException.toString());
      throw NetworkException('网络异常，请稍后再试');
    }
  }

  /// 处理令牌相关的问题
  Stream<Response> _handleTokenError(
      Request request, forward, Response response) async* {
    String message = response.errors!.first.message.toLowerCase();
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
          context: response.context,
          data: response.data,
          errors: error,
        );
      }
    } else {
      yield response;
    }
  }

  /// 刷新令牌
  Future<List<GraphQLError>> _refreshToken() async {
    final SharedPreferences prefs = await _prefs;
    _log.fine('refreshing token');
    String? refreshToken = prefs.getString('refreshToken');
    MutationOptions options = MutationOptions(
      document: gql(refreshTokenMutation),
      variables: {
        'input': {
          'refreshToken': refreshToken,
        }
      },
    );
    QueryResult results = await _client!.mutate(options);

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
    final SharedPreferences prefs = await _prefs;
    await prefs.setString('refreshToken', refreshToken);
  }

  Future _setToken(String token) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setString('token', token);
  }
}
