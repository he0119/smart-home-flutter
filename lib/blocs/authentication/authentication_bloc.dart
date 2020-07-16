import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/repositories/user_repository.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository userRepository;

  AuthenticationBloc({
    @required this.userRepository,
  }) : super(AuthenticationInitial());

  @override
  Stream<AuthenticationState> mapEventToState(
      AuthenticationEvent event) async* {
    if (event is AuthenticationStarted) {
      yield* _mapAuthenticationStartedToState(event);
    } else if (event is AuthenticationLogin) {
      yield* _mapLoginToState(event);
    } else if (event is AuthenticationLogout) {
      yield* _mapLogoutToState();
    }
  }

  Stream<AuthenticationState> _mapAuthenticationStartedToState(
      AuthenticationStarted event) async* {
    try {
      // 检查是否登录
      if (await userRepository.isLogin) {
        yield AuthenticationSuccess(await userRepository.currentUser());
      } else {
        yield AuthenticationFailure('未登录，请登录账户');
      }
    } catch (e) {
      yield AuthenticationError(e.message);
    }
  }

  Stream<AuthenticationState> _mapLoginToState(
      AuthenticationLogin event) async* {
    yield AuthenticationInProgress();
    try {
      bool result =
          await userRepository.authenticate(event.username, event.password);
      if (result) {
        User user = await userRepository.currentUser();
        yield AuthenticationSuccess(user);
      } else {
        yield AuthenticationFailure('用户名或密码错误');
      }
    } catch (e) {
      yield AuthenticationFailure(e.message);
    }
  }

  Stream<AuthenticationState> _mapLogoutToState() async* {
    yield AuthenticationFailure('已登出');
    await userRepository.logout();
  }
}
