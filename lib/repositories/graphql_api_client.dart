import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:smart_home/repositories/user_repository.dart';

GraphQLApiClient graphqlApiClient = GraphQLApiClient();

class GraphQLApiClient {
  static GraphQLClient _client;

  static final HttpLink _httpLink = HttpLink(
    uri: 'http://118.24.9.142:8000/graphql',
  );

  static final ErrorLink _errorLink = ErrorLink(errorHandler: (response) async {
    if (response.exception.graphqlErrors != null) {
      for (var error in response.exception.graphqlErrors) {
        print(
            '[GraphQL error]: Message: ${error.message}, Location: ${error.locations}, Path: ${error.path}');
        if (error.message.contains('expired') &&
            error.path[0] != 'refreshToken') {
          // FIX: 无法在刷新令牌之后使用更新的令牌访问到数据
          await userRepository.refreshToken();
        }
      }
    }

    if (response.exception.clientException != null) {
      print('[Network error]: ${response.exception.clientException}');
    }
  });
  static final AuthLink _authLink =
      AuthLink(getToken: () async => 'JWT ${await userRepository.token}');

  static final Link _link = _authLink.concat(_errorLink.concat(_httpLink));

  static final _prefix = 'home';

  GraphQLClient get client => _client;

  bool initailize() {
    _client = GraphQLClient(
      cache: InMemoryCache(storagePrefix: _prefix),
      link: _link,
    );
    return true;
  }

  Future<QueryResult> mutation(MutationOptions options) async {
    final results = await _client.mutate(options);
    if (results.hasException) {
      List<GraphQLError> exception = results.exception.graphqlErrors;
      print(exception.toString());
    }
    return results;
  }

  Future<QueryResult> query(QueryOptions options) async {
    final results = await _client.query(options);
    if (results.hasException) {
      List<GraphQLError> exception = results.exception.graphqlErrors;
      print(exception.toString());
    }
    return results;
  }
}
