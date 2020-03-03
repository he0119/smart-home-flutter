import 'dart:convert';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_home/graphql/mutations/mutations.dart';
import 'package:smart_home/graphql/queries/queries.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/models/serializers.dart';
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
      return false;
    } else {
      String token = results.data['tokenAuth']['token'];
      String refreshToken = results.data['tokenAuth']['refreshToken'];
      await setToken(token);
      await setRefreshToken(refreshToken);
      return true;
    }
  }

  Future clearToken() async {
    await _prefs.clear();
  }

  Future<User> currentUser() async {
    QueryOptions _options = QueryOptions(
      documentNode: gql(me),
    );
    QueryResult results = await graphqlApiClient.query(_options);
    User user =
        serializers.deserializeWith(User.serializer, results.data['me']);
    return user;
  }

  Future<bool> hasToken() async {
    String token = await userRepository.token;
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
    Map<String, dynamic> result = parseJwt(await token);
    int now = new DateTime.now().microsecondsSinceEpoch;
    // 本地时间可能与服务器不相等
    int exp = result['exp'] - 30;
    return exp > now;
  }

  Future<bool> refreshToken() async {
    String refreshToken = _prefs.getString('refreshToken');
    MutationOptions options = MutationOptions(
      documentNode: gql(refreshTokenMutation),
      variables: {
        'token': refreshToken,
      },
    );
    QueryResult results = await graphqlApiClient.client.mutate(options);
    if (results.hasException) {
      return false;
    } else {
      String token = results.data['refreshToken']['token'];
      await setToken(token);
      return true;
    }
  }

  Future setRefreshToken(String refreshToken) async {
    await _prefs.setString('refreshToken', refreshToken);
  }

  Future setToken(String token) async {
    await _prefs.setString('token', token);
  }
}
