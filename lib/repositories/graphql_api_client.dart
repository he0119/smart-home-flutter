import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_home/repositories/user_repository.dart';

class GraphQLApiClient {
  static final Logger _log = Logger('GraphQLApiClient');
  static GraphQLClient _client;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  UserRepository userRepository;

  GraphQLApiClient();

  GraphQLClient get client => _client;

  Future<String> get token async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString('token');
  }

  /// 清除 GraphQL 客户端的缓存
  Future clearCache() async {
    client.cache.reset(); // empty the hash map
    await client.cache.save(); // persist empty map to storage
    _log.fine('clear cache');
  }

  /// 初始化 GraphQL 客户端
  bool initailize({
    @required String url,
    @required UserRepository userRepository,
  }) {
    this.userRepository ??= userRepository;
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
      _log.fine('GraphQLClient initailized with url $url');
      return true;
    } catch (e) {
      _log.severe(e);
      return false;
    }
  }

  /// 更改
  Future<QueryResult> mutate(MutationOptions options) async {
    if (!await _isTokenValid()) {
      await userRepository.refreshToken();
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
      await userRepository.refreshToken();
    }
    final results = await _client.query(options);
    if (results.hasException) {
      _handleErrors(results.exception);
    }
    return results;
  }

  /// 清除 Token
  Future _clearToken() async {
    final SharedPreferences prefs = await _prefs;
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
}

/// 访问 API 出错
class GraphQLApiException implements Exception {
  final String message;

  GraphQLApiException({this.message});
}
