import 'package:graphql/client.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/user/graphql/mutations/mutations.dart';
import 'package:smarthome/user/graphql/queries/queries.dart';
import 'package:smarthome/user/model/user.dart';

class UserRepository {
  final GraphQLApiClient graphqlApiClient;

  UserRepository({required this.graphqlApiClient});

  Future<User> currentUser() async {
    final options = QueryOptions(
      document: gql(viewerQuery),
      fetchPolicy: FetchPolicy.networkOnly,
    );
    final results = await graphqlApiClient.query(options);
    final user = User.fromJson(results.data!['viewer']);
    return user;
  }

  Future<List<Session>> sessions() async {
    final options = QueryOptions(
      document: gql(sessionQuery),
      fetchPolicy: FetchPolicy.networkOnly,
    );
    final results = await graphqlApiClient.query(options);
    final List<dynamic> sessionsJson = results.data!['viewer']['session'];
    final sessions = sessionsJson.map((e) => Session.fromJson(e)).toList();
    return sessions;
  }

  Future<void> deleteSession(String id) async {
    final options = MutationOptions(
      document: opi(gql(deleteSessionMutation)),
      variables: {
        'input': {'id': id},
      },
    );
    await graphqlApiClient.mutate(options);
  }
}
