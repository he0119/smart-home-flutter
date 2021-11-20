import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:smarthome/core/repository/repositories.dart';
import 'package:smarthome/core/settings/settings_controller.dart';
import 'package:smarthome/user/user.dart';
import 'package:smarthome/utils/exceptions.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository userRepository;
  final GraphQLApiClient graphqlApiClient;
  final SettingsController settingsController;

  // 监控登录状态
  StreamSubscription<bool>? _loginSubscription;

  @override
  Future<void> close() {
    _loginSubscription?.cancel();
    return super.close();
  }

  AuthenticationBloc({
    required this.userRepository,
    required this.graphqlApiClient,
    required this.settingsController,
  }) : super(AuthenticationInitial()) {
    on<AuthenticationStarted>(_onAuthenticationStarted);
    on<AuthenticationLogin>(_onAuthenticationLogin);
    on<AuthenticationLogout>(_onAuthenticationLogout);
  }

  FutureOr<void> _onAuthenticationStarted(
      AuthenticationStarted event, Emitter<AuthenticationState> emit) async {
    try {
      // 检查是否登录
      if (settingsController.loginUser != null) {
        // 每次启动时都获取当前用户信息，并更新本地缓存
        final user = await userRepository.currentUser();
        await settingsController.updateLoginUser(user);
        emit(AuthenticationSuccess(user));
      } else {
        emit(const AuthenticationFailure('未登录，请登录账户'));
      }
    } on MyException catch (e) {
      emit(AuthenticationError(e.message));
    }
  }

  FutureOr<void> _onAuthenticationLogin(
      AuthenticationLogin event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationInProgress());
    try {
      final result =
          await graphqlApiClient.authenticate(event.username, event.password);
      if (result) {
        final user = await userRepository.currentUser();
        await settingsController.updateLoginUser(user);
        emit(AuthenticationSuccess(user));
      } else {
        emit(const AuthenticationFailure('用户名或密码错误'));
      }
    } on MyException catch (e) {
      emit(AuthenticationFailure(e.message));
    }
  }

  FutureOr<void> _onAuthenticationLogout(
      AuthenticationLogout event, Emitter<AuthenticationState> emit) async {
    emit(const AuthenticationFailure('已登出'));
    settingsController.updateLoginUser(null);
    // 清除 Sentry 设置的用户
    Sentry.configureScope((scope) => scope.user = null);
  }
}
