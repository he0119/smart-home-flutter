import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/services/graphql_service.dart';
import 'package:smart_home/services/user_service.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

Stream<AuthenticationState> _mapAppStartedToState() async* {
  try {
    await userService.initailize();
    graphqlService.initailize();
    if (await userService.hasToken()) {
      yield Unauthenticated('请登录');
    } else {
      yield Authenticated(await userService.currentUser());
    }
  } catch (_) {
    yield Unauthenticated('未知错误，请登录');
  }
}

Stream<AuthenticationState> _mapLoginToState(AuthenticationLogin event) async* {
  bool result = await userService.authenticate(event.username, event.password);
  if (result) {
    yield Authenticated(await userService.currentUser());
  } else {
    yield Unauthenticated('登陆失败');
  }
}

Stream<AuthenticationState> _mapLogoutToState() async* {
  await userService.clearToken();
  yield Unauthenticated('注销成功');
}

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  @override
  AuthenticationState get initialState => AppUninitialized();

  @override
  Stream<AuthenticationState> mapEventToState(
      AuthenticationEvent event) async* {
    if (event is AppStarted) {
      yield* _mapAppStartedToState();
    } else if (event is AuthenticationLogin) {
      yield* _mapLoginToState(event);
    } else if (event is AuthenticationLogout) {
      yield* _mapLogoutToState();
    }
  }
}
