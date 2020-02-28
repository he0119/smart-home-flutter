import 'package:smart_home/services/shared_preferences_service.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class Client {
  static GraphQLClient initailizeClient(String prefix) {
    final HttpLink httpLink = HttpLink(
      uri: 'http://127.0.0.1:8000/graphql',
    );

    final AuthLink _authLink =
        AuthLink(getToken: () async => await sharedPreferenceService.token);

    final Link _link = _authLink.concat(httpLink);

    return GraphQLClient(
      cache: InMemoryCache(storagePrefix: prefix),
      link: _link,
    );
  }
}
