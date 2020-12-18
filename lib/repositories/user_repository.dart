import 'package:flutter/foundation.dart';
import 'package:graphql/client.dart';
import 'package:smart_home/graphql/queries/viewer.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/repositories/graphql_api_client.dart';

class UserRepository {
  // static final Logger _log = Logger('UserRepository');
  final GraphQLApiClient graphqlApiClient;

  UserRepository({@required this.graphqlApiClient});

  Future<User> currentUser() async {
    QueryOptions _options = QueryOptions(
      document: gql(viewer),
    );
    QueryResult results = await graphqlApiClient.query(_options);
    User user = User.fromJson(results.data['viewer']);
    return user;
  }
}
