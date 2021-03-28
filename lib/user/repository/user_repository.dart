import 'package:graphql/client.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/user/graphql/queries/viewer.dart';
import 'package:smarthome/user/model/user.dart';

class UserRepository {
  final GraphQLApiClient graphqlApiClient;

  UserRepository({required this.graphqlApiClient});

  Future<User> currentUser() async {
    final _options = QueryOptions(
      document: gql(viewer),
      fetchPolicy: FetchPolicy.networkOnly,
    );
    final results = await graphqlApiClient.query(_options);
    final user = User.fromJson(results.data!['viewer']);
    return user;
  }
}
