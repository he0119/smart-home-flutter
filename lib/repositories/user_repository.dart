import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_home/blocs/authentication/authentication_bloc.dart';
import 'package:smart_home/graphql/mutations/mutations.dart';
import 'package:smart_home/graphql/queries/me.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/repositories/graphql_api_client.dart';

class UserRepository {
  static final Logger _log = Logger('UserRepository');
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final GraphQLApiClient graphqlApiClient;
  AuthenticationBloc authenticationBloc;

  UserRepository({@required this.graphqlApiClient});

  /// 是否登录
  /// 通过判断是否拥有 Refresh Token
  Future<bool> get isLogin async {
    final SharedPreferences prefs = await _prefs;
    String token = prefs.getString('refreshToken');
    if (token == null || token == '') {
      return false;
    } else {
      return true;
    }
  }

  /// 登录
  Future<bool> authenticate(String username, String password) async {
    MutationOptions loginOptions = MutationOptions(
      documentNode: gql(tokenAuth),
      variables: {
        'username': username,
        'password': password,
      },
    );
    QueryResult results = await graphqlApiClient.client.mutate(loginOptions);
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

  Future<User> currentUser() async {
    QueryOptions _options = QueryOptions(
      documentNode: gql(me),
    );
    QueryResult results = await graphqlApiClient.query(_options);
    User user = User.fromJson(results.data['me']);
    return user;
  }

  /// 登出
  Future logout() async {
    await _clearRefreshToken();
  }

  /// 刷新 Token
  Future refreshToken() async {
    final SharedPreferences prefs = await _prefs;
    _log.fine('refreshing token');
    String refreshToken = prefs.getString('refreshToken');
    MutationOptions options = MutationOptions(
      documentNode: gql(refreshTokenMutation),
      variables: {
        'token': refreshToken,
      },
    );
    QueryResult results = await graphqlApiClient.client.mutate(options);
    if (results.hasException) {
      for (GraphQLError error in results.exception.graphqlErrors) {
        // 如果 Refresh Token 无效或过期则登出
        String message = error.message.toLowerCase();
        if (message.contains('invalid') || message.contains('expired')) {
          authenticationBloc.add(AuthenticationLogout());
        }
        _log.warning('refresh token expired/invalid');
        throw AuthenticationException('登录验证失败，请重新登录');
      }
    } else {
      String token = results.data['refreshToken']['token'];
      await _setToken(token);
      _log.fine('token refreshed');
    }
  }

  /// 清除 Refresh Token
  Future _clearRefreshToken() async {
    final SharedPreferences prefs = await _prefs;
    await prefs.remove('refreshToken');
    _log.fine('clear refresh token');
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

/// 访问 API 出错
class AuthenticationException implements Exception {
  final String message;

  const AuthenticationException(this.message);
}
