import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:smart_home/repositories/user_repository.dart';

GraphQLApiClient graphqlApiClient = GraphQLApiClient();

class GraphQLApiException implements Exception {
  final String message;

  GraphQLApiException({this.message});
}

class GraphQLApiClient {
  static GraphQLClient _client;

  static final AuthLink _authLink =
      AuthLink(getToken: () async => 'JWT ${await userRepository.token}');

  GraphQLClient get client => _client;

  void _handleErrors(OperationException errors) {
    if (errors.clientException != null) {
      throw GraphQLApiException(message: '网络连接出错，请稍后再试');
    }
    for (GraphQLError error in errors.graphqlErrors) {
      String message = error.message.toLowerCase();
      // Token 格式出错，直接清除 Token
      if (message.contains('error decoding signature')) {
        userRepository.clearToken();
        throw GraphQLApiException(message: '认证出错，请稍后再试');
      }
    }
    throw GraphQLApiException(message: errors.graphqlErrors[0].message);
  }

  bool initailize(String url) {
    final HttpLink _httpLink = HttpLink(
      uri: url,
    );
    final Link _link = _authLink.concat(_httpLink);
    try {
      _client = GraphQLClient(
        cache: OptimisticCache(dataIdFromObject: typenameDataIdFromObject),
        link: _link,
      );
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future clearCache() async {
    client.cache.reset(); // empty the hash map
    await client.cache.save(); // persist empty map to storage
  }

  Future<QueryResult> mutate(MutationOptions options) async {
    if (!await userRepository.isTokenValid()) {
      await userRepository.refreshToken();
    }
    final results = await _client.mutate(options);
    if (results.hasException) {
      _handleErrors(results.exception);
    }
    return results;
  }

  Future<QueryResult> query(QueryOptions options) async {
    if (!await userRepository.isTokenValid()) {
      await userRepository.refreshToken();
    }
    final results = await _client.query(options);
    if (results.hasException) {
      _handleErrors(results.exception);
    }
    return results;
  }
}
