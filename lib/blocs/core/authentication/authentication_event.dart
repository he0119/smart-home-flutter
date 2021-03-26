part of 'authentication_bloc.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];
}

/// 开始确认用户身份
class AuthenticationStarted extends AuthenticationEvent {
  @override
  String toString() => 'AuthenticationStarted';
}

/// 登录
class AuthenticationLogin extends AuthenticationEvent {
  final String username;
  final String password;

  const AuthenticationLogin({
    required this.username,
    required this.password,
  });

  @override
  List<Object> get props => [username, password];

  @override
  String toString() =>
      'AuthenticationLogin(username: $username, password: $password)';
}

/// 登出
class AuthenticationLogout extends AuthenticationEvent {
  @override
  String toString() => 'AuthenticationLogout';
}
