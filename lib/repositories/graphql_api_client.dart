import 'dart:async';

import 'package:graphql/client.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_home/graphql/mutations/mutations.dart';

class GraphQLApiClient {
  static final Logger _log = Logger('GraphQLApiClient');
  static GraphQLClient _client;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  GraphQLApiClient();

  GraphQLClient get client => _client;

  Future<String> get token async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString('token');
  }

  /// 初始化 GraphQL 客户端
  bool initailize(String url) {
    final AuthLink _authLink =
        AuthLink(getToken: () async => 'JWT ${await token}');
    final HttpLink _httpLink = HttpLink(url);
    final ErrorLink _tokenErrorLink =
        ErrorLink(onGraphQLError: handleTokenError);
    final Link _link = Link.from([
      DedupeLink(),
      _tokenErrorLink,
    ]).split((request) {
      for (var definition in request.operation.document.definitions) {
        final String operationName = definition.name.value;
        if (operationName == 'tokenAuth' || operationName == 'refreshToken') {
          return false;
        }
      }
      return true;
    }, _authLink.concat(_httpLink), _httpLink);
    try {
      _client = GraphQLClient(
        cache: GraphQLCache(),
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
    final results = await _client.mutate(options);
    return results;
  }

  /// 查询
  Future<QueryResult> query(QueryOptions options) async {
    final results = await _client.query(options);
    return results;
  }

  /// 登录
  Future<bool> authenticate(String username, String password) async {
    MutationOptions loginOptions = MutationOptions(
      document: gql(tokenAuth),
      variables: {
        'username': username,
        'password': password,
      },
    );
    QueryResult results = await _client.mutate(loginOptions);
    if (results.hasException) {
      if (results.exception.linkException != null) {
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

  /// 刷新 Token
  Future refreshToken() async {
    final SharedPreferences prefs = await _prefs;
    _log.fine('refreshing token');
    String refreshToken = prefs.getString('refreshToken');
    MutationOptions options = MutationOptions(
      document: gql(refreshTokenMutation),
      variables: {
        'token': refreshToken,
      },
    );
    QueryResult results = await _client.mutate(options);
    if (!results.hasException) {
      String token = results.data['refreshToken']['token'];
      await _setToken(token);
      _log.fine('token refreshed');
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

  /// 处理令牌相关的问题
  Stream<Response> handleTokenError(
      Request request, forward, Response response) async* {
    String message = response.errors[0].message.toLowerCase();
    if (message.contains('signature has expired')) {
      // 如果访问令牌失效，则自动刷新
      await refreshToken();
    }
    if (message.contains('invalid refresh token')) {
      // 刷新令牌无效时，删除刷新令牌
      await _clearToken();
      await _clearRefreshToken();
      throw AuthenticationException('登陆失效，请重新登录');
    }
    yield* forward(request);
  }

  /// 清除 Token
  Future _clearToken() async {
    final SharedPreferences prefs = await _prefs;
    await prefs.remove('token');
    _log.fine('clear token');
  }

  /// 清除 Token
  Future _clearRefreshToken() async {
    final SharedPreferences prefs = await _prefs;
    await prefs.remove('refreshToken');
    _log.fine('clear refresh token');
  }
}

/// 访问 API 出错
class GraphQLApiException implements Exception {
  final String message;

  GraphQLApiException({this.message});
}

/// 访问令牌失效
class AccessTokenException implements Exception {}

/// 认证出错
class AuthenticationException implements Exception {
  final String message;

  const AuthenticationException(this.message);
}
