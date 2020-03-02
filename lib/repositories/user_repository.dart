import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_home/graphql/mutations/mutations.dart';
import 'package:smart_home/graphql/queries/queries.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/models/serializers.dart';
import 'package:smart_home/repositories/graphql_api_client.dart';

UserRepository userRepository = UserRepository();

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
    QueryResult results = await graphqlApiClient.mutation(loginOptions);
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
    print(token);
    if (token == null || token == "") {
      return false;
    } else {
      return true;
    }
  }

  Future<bool> refreshToken() async {
    String refreshToken = _prefs.getString('refreshToken');
    MutationOptions options = MutationOptions(
      documentNode: gql(refreshTokenMutation),
      variables: {
        'token': refreshToken,
      },
    );
    QueryResult results = await graphqlApiClient.mutation(options);
    if (results.hasException) {
      return false;
    } else {
      String token = results.data['refreshToken']['token'];
      await setToken(token);
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

  Future setToken(String token) async {
    await _prefs.setString('token', token);
  }

  Future setRefreshToken(String refreshToken) async {
    await _prefs.setString('refreshToken', refreshToken);
  }
}
