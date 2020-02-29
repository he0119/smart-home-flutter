import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:smart_home/services/shared_preferences_service.dart';

GraphQLService graphqlService = GraphQLService();

class GraphQLService {
  static GraphQLClient _client;

  static final HttpLink _httpLink = HttpLink(
    uri: 'http://127.0.0.1:8000/graphql',
  );
  static final _prefix = 'home';

  GraphQLClient get client => _client;

  void initailizeClient() {
    final AuthLink _authLink =
        AuthLink(getToken: () async => 'JWT ${await sharedPreferenceService.token}');

    final Link _link = _authLink.concat(_httpLink);

    _client = GraphQLClient(
      cache: InMemoryCache(storagePrefix: _prefix),
      link: _link,
    );
  }

  Future<QueryResult> mutation(MutationOptions options) async {
    final results = await _client.mutate(options);
    if (results.hasException) {}
    return results;
  }

  Future<QueryResult> query(QueryOptions options) async {
    final results = await _client.query(options);
    if (results.hasException) {}
    return results;
  }

  void reloadClient() {
    initailizeClient();
  }
}
