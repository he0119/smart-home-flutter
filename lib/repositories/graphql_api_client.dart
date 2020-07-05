import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_home/graphql/mutations/mutations.dart';

class GraphQLApiClient {
  static GraphQLClient _client;
  static final Logger _log = Logger('GraphQLApiClient');

  final SharedPreferences prefs;

  GraphQLApiClient({@required this.prefs});

  GraphQLClient get client => _client;

  /// 是否登录
  /// 通过判断是否拥有 Refresh Token
  bool get isLogin {
    String token = prefs.getString('refreshToken');
    if (token == null || token == "") {
      return false;
    } else {
      return true;
    }
  }

  Future<String> get token async => prefs.getString('token');

  /// 登录
  Future<bool> authenticate(String username, String password) async {
    MutationOptions loginOptions = MutationOptions(
      documentNode: gql(tokenAuth),
      variables: {
        'username': username,
        'password': password,
      },
    );
    QueryResult results = await client.mutate(loginOptions);
    if (results.hasException) {
      if (results.exception.clientException != null) {
        throw Exception('网络异常，请稍后再试');
      }
      return false;
    } else {
      String token = results.data['tokenAuth']['token'];
      String refreshToken = results.data['tokenAuth']['refreshToken'];
      await _setToken(token);
      await _setRefreshToken(refreshToken);
      return true;
    }
  }

  /// 清除 GraphQL 客户端的缓存
  Future clearCache() async {
    client.cache.reset(); // empty the hash map
    await client.cache.save(); // persist empty map to storage
    _log.fine('clear cache');
  }

  /// 初始化 GraphQL 客户端
  bool initailize(String url) {
    final AuthLink _authLink =
        AuthLink(getToken: () async => 'JWT ${await token}');
    final HttpLink _httpLink = HttpLink(
      uri: url,
    );
    final Link _link = _authLink.concat(_httpLink);
    try {
      _client = GraphQLClient(
        cache: OptimisticCache(dataIdFromObject: typenameDataIdFromObject),
        link: _link,
      );
      return true;
    } catch (e) {
      _log.severe(e);
      return false;
    }
  }

  /// 登出
  Future logout() async {
    await _clearToken();
    await _clearRefreshToken();
    await clearCache();
  }

  /// 更改
  Future<QueryResult> mutate(MutationOptions options) async {
    if (!await _isTokenValid()) {
      await _refreshToken();
    }
    final results = await _client.mutate(options);
    if (results.hasException) {
      _handleErrors(results.exception);
    }
    return results;
  }

  /// 查询
  Future<QueryResult> query(QueryOptions options) async {
    if (!await _isTokenValid()) {
      await _refreshToken();
    }
    final results = await _client.query(options);
    if (results.hasException) {
      _handleErrors(results.exception);
    }
    return results;
  }

  /// 清除 Refresh Token
  Future _clearRefreshToken() async {
    await prefs.clear();
    _log.fine('clear refresh token');
  }

  /// 清除 Token
  Future _clearToken() async {
    await prefs.remove('token');
    _log.fine('clear token');
  }

  String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');

    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Illegal base64url string!"');
    }

    return utf8.decode(base64Url.decode(output));
  }

  void _handleErrors(OperationException errors) {
    if (errors.clientException != null) {
      throw GraphQLApiException(message: '网络连接出错，请稍后再试');
    }
    for (GraphQLError error in errors.graphqlErrors) {
      String message = error.message.toLowerCase();
      // Token 格式出错，直接清除 Token
      if (message.contains('error decoding signature')) {
        _clearToken();
        throw GraphQLApiException(message: '认证出错，请稍后再试');
      }
    }
    throw GraphQLApiException(message: errors.graphqlErrors[0].message);
  }

  /// 检查 Token 是否过期
  Future<bool> _isTokenValid() async {
    try {
      Map<String, dynamic> result = _parseJwt(await token);
      int now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      // 本地时间可能与服务器不相等
      int exp = result['exp'] - 30;
      return exp > now;
    } catch (e) {
      return false;
    }
  }

  Map<String, dynamic> _parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('invalid token');
    }

    final payload = _decodeBase64(parts[1]);
    final payloadMap = json.decode(payload);
    if (payloadMap is! Map<String, dynamic>) {
      throw Exception('invalid payload');
    }

    return payloadMap;
  }

  /// 刷新 Token
  Future _refreshToken() async {
    _log.fine('refreshing token');
    String refreshToken = prefs.getString('refreshToken');
    MutationOptions options = MutationOptions(
      documentNode: gql(refreshTokenMutation),
      variables: {
        'token': refreshToken,
      },
    );
    QueryResult results = await client.mutate(options);
    if (results.hasException) {
      for (GraphQLError error in results.exception.graphqlErrors) {
        // 如果 Refresh Token 无效或过期则清除
        String message = error.message.toLowerCase();
        if (message.contains('invalid') || message.contains('expired')) {
          _clearRefreshToken();
        }
        _log.warning('refresh token expired/invalid');
        throw Exception('登录验证失败，请重新登录');
      }
    } else {
      String token = results.data['refreshToken']['token'];
      await _setToken(token);
      _log.fine('token refreshed');
    }
  }

  Future _setRefreshToken(String refreshToken) async {
    await prefs.setString('refreshToken', refreshToken);
  }

  Future _setToken(String token) async {
    await prefs.setString('token', token);
  }
}

/// 访问 API 出错
class GraphQLApiException implements Exception {
  final String message;

  GraphQLApiException({this.message});
}
