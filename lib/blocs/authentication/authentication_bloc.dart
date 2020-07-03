import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/repositories/graphql_api_client.dart';
import 'package:smart_home/repositories/user_repository.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

Stream<AuthenticationState> _mapAppStartedToState(AppStarted event) async* {
  try {
    // 初始化
    if (!await userRepository.initailize()) {
      yield AuthenticationError('客户端启动失败，请重试');
    }
    if (!graphqlApiClient.initailize(event.url)) {
      yield AuthenticationError('客户端启动失败，请重试');
    }
    // 检查是否登录
    yield Authenticating();
    if (userRepository.hasToken()) {
      yield Authenticated(await userRepository.currentUser());
    } else {
      yield Unauthenticated();
    }
  } on GraphQLApiException catch (e) {
    yield AuthenticationError(e.message);
  }
}

Stream<AuthenticationState> _mapLoginToState(AuthenticationLogin event) async* {
  yield Authenticating();
  try {
    bool result =
        await userRepository.authenticate(event.username, event.password);
    if (result) {
      User user = await userRepository.currentUser();
      yield Authenticated(user);
    } else {
      yield AuthenticationFailure('用户名或密码错误');
    }
  } catch (e) {
    yield AuthenticationFailure(e.message);
  }
}

Stream<AuthenticationState> _mapLogoutToState() async* {
  await userRepository.clearToken();
  yield Unauthenticated();
}

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc() : super(AppUninitialized());

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
