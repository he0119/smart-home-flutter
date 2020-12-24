import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_home/blocs/app_preferences/app_preferences_bloc.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/repositories/graphql_api_client.dart';
import 'package:smart_home/repositories/user_repository.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository userRepository;
  final GraphQLApiClient graphqlApiClient;
  final AppPreferencesBloc appPreferencesBloc;

  // 监控登录状态
  StreamSubscription<bool> _loginSubscription;

  @override
  Future<void> close() {
    _loginSubscription?.cancel();
    return super.close();
  }

  AuthenticationBloc({
    @required this.userRepository,
    @required this.graphqlApiClient,
    @required this.appPreferencesBloc,
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
    // 监听认证情况
    if (_loginSubscription == null) {
      _loginSubscription = graphqlApiClient.loginStatus.listen((event) {
        if (!event) {
          add(AuthenticationLogout());
        }
      });
    }
    try {
      // 检查是否登录
      if (await graphqlApiClient.isLogin) {
        if (appPreferencesBloc.state.loginUser != null) {
          yield AuthenticationSuccess(appPreferencesBloc.state.loginUser);
        } else {
          User user = await userRepository.currentUser();
          appPreferencesBloc.add(LoginUserChanged(loginUser: user));
          yield AuthenticationSuccess(user);
        }
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
          await graphqlApiClient.authenticate(event.username, event.password);
      if (result) {
        User user = await userRepository.currentUser();
        appPreferencesBloc.add(LoginUserChanged(loginUser: user));
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
    await graphqlApiClient.logout();
  }
}
