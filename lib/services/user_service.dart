import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_home/graphql/mutations/mutations.dart';
import 'package:smart_home/graphql/queries/queries.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/models/serializers.dart';
import 'package:smart_home/services/graphql_service.dart';

UserService userService = UserService();

class UserService {
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
    QueryResult results = await graphqlService.mutation(loginOptions);
    if (results.hasException) {
      return false;
    } else {
      String token = results.data['tokenAuth']['token'];
      await setToken(token);
      graphqlService.reloadClient();
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
    QueryResult results = await graphqlService.query(_options);
    User user =
        serializers.deserializeWith(User.serializer, results.data['me']);
    return user;
  }

  Future<bool> hasToken() async {
    String _token = await userService.token;
    if (_token == null || _token == "") {
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

  Future setToken(String token) async {
    await _prefs.setString('token', token);
  }
}
