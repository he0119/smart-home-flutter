import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:smart_home/repositories/user_repository.dart';

GraphQLApiClient graphqlApiClient = GraphQLApiClient();

class GraphQLApiClient {
  static GraphQLClient _client;

  static final HttpLink _httpLink = HttpLink(
    uri: 'http://118.24.9.142:8000/graphql',
  );

  static final AuthLink _authLink =
      AuthLink(getToken: () async => 'JWT ${await userRepository.token}');

  static final Link _link = _authLink.concat(_httpLink);

  static final _prefix = 'home';

  GraphQLClient get client => _client;

  bool initailize() {
    _client = GraphQLClient(
      cache: InMemoryCache(storagePrefix: _prefix),
      link: _link,
    );
    return true;
  }

  Future<QueryResult> mutate(MutationOptions options) async {
    if (!await userRepository.isTokenValid()) {
      await userRepository.refreshToken();
    }
    final results = await _client.mutate(options);
    return results;
  }

  Future<QueryResult> query(QueryOptions options) async {
    if (!await userRepository.isTokenValid()) {
      await userRepository.refreshToken();
    }
    final results = await _client.query(options);
    return results;
  }
}
