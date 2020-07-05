import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:smart_home/graphql/queries/me.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/repositories/graphql_api_client.dart';

class UserRepository {
  final GraphQLApiClient graphqlApiClient;

  UserRepository({@required this.graphqlApiClient});

  Future<User> currentUser() async {
    QueryOptions _options = QueryOptions(
      documentNode: gql(me),
    );
    QueryResult results = await graphqlApiClient.query(_options);
    User user = User.fromJson(results.data['me']);
    return user;
  }
}
