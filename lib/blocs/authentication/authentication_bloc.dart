import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/repositories/graphql_api_client.dart';
import 'package:smart_home/repositories/user_repository.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

Stream<AuthenticationState> _mapAppStartedToState(AppStarted event) async* {
  try {
    await userRepository.initailize();
    graphqlApiClient.initailize(event.url);
    if (await userRepository.hasToken()) {
      yield Authenticated(await userRepository.currentUser());
    } else {
      yield Unauthenticated();
    }
  } catch (_) {
    yield Unauthenticated();
  }
}

Stream<AuthenticationState> _mapLoginToState(AuthenticationLogin event) async* {
  yield Authenticating();
  bool result =
      await userRepository.authenticate(event.username, event.password);
  if (result) {
    User user = await userRepository.currentUser();
    yield Authenticated(user);
  } else {
    yield AuthenticationFailure('用户名或密码错误');
  }
}

Stream<AuthenticationState> _mapLogoutToState() async* {
  await userRepository.clearToken();
  yield Unauthenticated();
}

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  @override
  AuthenticationState get initialState => AppUninitialized();

  @override
  Stream<AuthenticationState> mapEventToState(
      AuthenticationEvent event) async* {
    if (event is AppStarted) {
      yield* _mapAppStartedToState(event);
    } else if (event is AuthenticationLogin) {
      yield* _mapLoginToState(event);
    } else if (event is AuthenticationLogout) {
      yield* _mapLogoutToState();
    }
  }
}
