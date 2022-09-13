import 'dart:async';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:graphql/client.dart' hide NetworkException, ServerException;
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarthome/app/settings/settings_controller.dart';
import 'package:smarthome/core/graphql/mutations/mutations.dart';
import 'package:smarthome/user/model/user.dart';
import 'package:smarthome/utils/exceptions.dart';

class ClientWithCookies extends IOClient {
  final PersistCookieJar cookieJar = PersistCookieJar();

  @override
  Future<IOStreamedResponse> send(BaseRequest request) async {
    final cookie = await cookieJar.loadForRequest(request.url);
    if (cookie.isNotEmpty) {
      final cookiesString =
          cookie.map((e) => '${e.name}=${e.value}').join('; ');
      request.headers['cookie'] = cookiesString;
    }
    return super.send(request).then((response) {
      final cookiesString = response.headers['set-cookie'];
      final request = response.request;
      if (cookiesString != null && request != null) {
        // 这个分割真的难受，不知道还没有更好的方法
        // cookie 有效期的格式中包含了逗号
        final cookieStringList = cookiesString.split(',');
        List<Cookie> cookies = [];
        for (var i = 0; i < cookieStringList.length; i += 2) {
          cookies.add(Cookie.fromSetCookieValue(
              cookieStringList[i] + cookieStringList[i + 1]));
        }
        cookieJar.saveFromResponse(request.url, cookies);
      }
      return response;
    });
  }
}

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
  Future<User?> authenticate(String username, String password) async {
    final loginOptions = MutationOptions(
      document: gql(loginMutation),
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
      return null;
    } else {
      final data = results.data!['login'];
      if (data['__typename'] == 'User') {
        final user = User.fromJson(data);
        return user;
      }
    }
    return null;
  }

  Future<bool> logout() async {
    final loginOptions = MutationOptions(
      document: gql(logoutMutation),
    );
    final results = await mutate(loginOptions);
    if (results.hasException) {
      if (results.exception!.linkException != null) {
        throw const NetworkException('网络异常，请稍后再试');
      }
      return false;
    } else {
      return true;
    }
  }

  /// 初始化 GraphQL 客户端
  void initailize(String url) {
    Link link;
    if (!kIsWeb) {
      link = HttpLink(
        url,
        httpClient: ClientWithCookies(),
        defaultHeaders: headers,
      );
    } else {
      link = HttpLink(
        url,
        defaultHeaders: headers,
      );
    }

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
      if (error.message == 'User is not authenticated') {
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
}
