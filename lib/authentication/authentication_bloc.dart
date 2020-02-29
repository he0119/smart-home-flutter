import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:smart_home/services/graphql_service.dart';
import 'package:smart_home/services/shared_preferences_service.dart';
import 'package:smart_home/storage/graphql/mutations/mutations.dart';
import 'package:smart_home/storage/graphql/queries/queries.dart';
import 'package:smart_home/storage/models/models.dart';
import 'package:smart_home/storage/models/serializers.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

Future<User> currentUser() async {
  QueryOptions _options = QueryOptions(
    documentNode: gql(me),
  );
  QueryResult results = await graphqlService.query(_options);
  User user = serializers.deserializeWith(User.serializer, results.data['me']);
  return user;
}

Stream<AuthenticationState> _mapAppStartedToState() async* {
  try {
    await sharedPreferenceService.getSharedPreferencesInstance();
    graphqlService.initailizeClient();
    String _token = await sharedPreferenceService.token;
    if (_token == null || _token == "") {
      yield Unauthenticated();
    } else {
      yield Authenticated(await currentUser());
    }
  } catch (_) {
    yield Unauthenticated();
  }
}

Stream<AuthenticationState> _mapLogInToState(LogIn event) async* {
  MutationOptions loginOptions = MutationOptions(
    documentNode: gql(tokenAuth),
    variables: {
      'username': event.username,
      'password': event.password,
    },
  );
  QueryResult results = await graphqlService.mutation(loginOptions);
  if (results.hasException) {
    print(results.exception.toString());
  }
  String token = results.data['tokenAuth']['token'];
  await sharedPreferenceService.setToken(token);
  graphqlService.reloadClient();
  yield Authenticated(await currentUser());
}

Stream<AuthenticationState> _mapLogOutToState() async* {
  yield Unauthenticated();
}

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  @override
  AuthenticationState get initialState => Uninitialized();

  @override
  Stream<AuthenticationState> mapEventToState(
      AuthenticationEvent event) async* {
    if (event is AppStarted) {
      yield* _mapAppStartedToState();
    } else if (event is LogIn) {
      yield* _mapLogInToState(event);
    } else if (event is LogOut) {
      yield* _mapLogOutToState();
    }
  }
}
