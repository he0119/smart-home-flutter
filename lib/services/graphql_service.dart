import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:smart_home/services/user_service.dart';

GraphQLService graphqlService = GraphQLService();

class GraphQLService {
  static GraphQLClient _client;

  static final HttpLink _httpLink = HttpLink(
    uri: 'http://118.24.9.142:8000/graphql',
  );

  static final ErrorLink _errorLink = ErrorLink(errorHandler: (response) {
    if (response.exception.graphqlErrors != null) {
      for (var error in response.exception.graphqlErrors) {
        print(
            '[GraphQL error]: Message: ${error.message}, Location: ${error.locations}, Path: ${error.path}');
      }
    }

    if (response.exception.clientException != null) {
      print('[Network error]: ${response.exception.clientException}');
    }
  });
  static final _prefix = 'home';

  GraphQLClient get client => _client;

  bool initailize() {
    final AuthLink authLink =
        AuthLink(getToken: () async => 'JWT ${await userService.token}');

    final Link link = authLink.concat(_errorLink.concat(_httpLink));

    _client = GraphQLClient(
      cache: InMemoryCache(storagePrefix: _prefix),
      link: link,
    );
    return true;
  }

  Future<QueryResult> mutation(MutationOptions options) async {
    final results = await _client.mutate(options);
    if (results.hasException) {
      List<GraphQLError> exception = results.exception.graphqlErrors;
      print(exception.length);
    }
    return results;
  }

  Future<QueryResult> query(QueryOptions options) async {
    final results = await _client.query(options);
    if (results.hasException) {
      List<GraphQLError> exception = results.exception.graphqlErrors;
      print(exception.length);
    }
    return results;
  }

  void reloadClient() {
    initailize();
  }
}
