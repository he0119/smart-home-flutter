import 'dart:convert';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_home/graphql/mutations/mutations.dart';
import 'package:smart_home/graphql/queries/me.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/repositories/graphql_api_client.dart';

UserRepository userRepository = UserRepository();

Map<String, dynamic> parseJwt(String token) {
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

class UserRepository {
  SharedPreferences _prefs;

  Future<String> get token async => _prefs.getString('token');

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
      await setToken(token);
      await setRefreshToken(refreshToken);
      return true;
    }
  }

  Future clearRefreshToken() async {
    await _prefs.clear();
  }

  Future clearToken() async {
    await _prefs.remove('token');
  }

  Future<User> currentUser() async {
    QueryOptions _options = QueryOptions(
      documentNode: gql(me),
    );
    QueryResult results = await graphqlApiClient.query(_options);
    User user = User.fromJson(results.data['me']);
    return user;
  }

  bool hasToken() {
    String token = _prefs.getString('refreshToken');
    if (token == null || token == "") {
      return false;
    } else {
      return true;
    }
  }

  Future<bool> initailize() async {
    _prefs = await SharedPreferences.getInstance().catchError((e) {
      print("shared prefrences error : $e");
      return false;
    });
    return true;
  }

  Future<bool> isTokenValid() async {
    try {
      Map<String, dynamic> result = parseJwt(await token);
      int now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      // 本地时间可能与服务器不相等
      int exp = result['exp'] - 30;
      return exp > now;
    } catch (e) {
      return false;
    }
  }

  Future refreshToken() async {
    String refreshToken = _prefs.getString('refreshToken');
    print('refresh token');
    MutationOptions options = MutationOptions(
      documentNode: gql(refreshTokenMutation),
      variables: {
        'token': refreshToken,
      },
    );
    QueryResult results = await graphqlApiClient.client.mutate(options);
    if (results.hasException) {
      for (GraphQLError error in results.exception.graphqlErrors) {
        // 如果 Refresh Token 无效或过期则清除
        String message = error.message.toLowerCase();
        if (message.contains('invalid') || message.contains('expired')) {
          clearRefreshToken();
        }
        throw Exception('登录验证失败，请重新登录');
      }
    } else {
      String token = results.data['refreshToken']['token'];
      await setToken(token);
    }
  }

  Future setRefreshToken(String refreshToken) async {
    await _prefs.setString('refreshToken', refreshToken);
  }

  Future setToken(String token) async {
    await _prefs.setString('token', token);
  }
}
