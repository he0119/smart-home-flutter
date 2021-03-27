import 'package:graphql/client.dart';
import 'package:smarthome/app/graphql_api_client.dart';
import 'package:smarthome/user/graphql/queries/viewer.dart';
import 'package:smarthome/user/model/user.dart';

class UserRepository {
  // static final Logger _log = Logger('UserRepository');
  final GraphQLApiClient graphqlApiClient;

  UserRepository({required this.graphqlApiClient});

  Future<User> currentUser() async {
    QueryOptions _options = QueryOptions(
      document: gql(viewer),
      fetchPolicy: FetchPolicy.networkOnly,
    );
    QueryResult results = await graphqlApiClient.query(_options);
    User user = User.fromJson(results.data!['viewer']);
    return user;
  }
}
