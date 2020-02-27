import 'package:smart_home/services/shared_preferences_service.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class Client {
  static final HttpLink httpLink = HttpLink(
    uri: 'http://118.24.9.142:8000/graphql',
  );

  static final AuthLink _authLink = AuthLink(
      getToken: () async => 'JWT ${await sharedPreferenceService.token}');

  static final Link _link = _authLink.concat(HttpLink as Link);

  static GraphQLClient initailizeClient() {
    return GraphQLClient(
      cache: InMemoryCache(),
      link: _link,
    );
  }
}
