import 'package:flutter/foundation.dart';
import 'package:graphql/client.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_home/graphql/queries/viewer.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/repositories/graphql_api_client.dart';

class UserRepository {
  static final Logger _log = Logger('UserRepository');
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final GraphQLApiClient graphqlApiClient;

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

  Future<User> currentUser() async {
    QueryOptions _options = QueryOptions(
      document: gql(viewer),
    );
    QueryResult results = await graphqlApiClient.query(_options);
    User user = User.fromJson(results.data['viewer']);
    return user;
  }

  /// 登出
  Future logout() async {
    final SharedPreferences prefs = await _prefs;
    await prefs.remove('refreshToken');
    await prefs.remove('loginUser');
    _log.fine('clear refresh token');
  }
}
