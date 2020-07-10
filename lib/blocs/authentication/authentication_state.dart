part of 'authentication_bloc.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object> get props => [];
}

class AuthenticationUninitialized extends AuthenticationState {}

class Authenticating extends AuthenticationState {}

class Authenticated extends AuthenticationState {
  final User currentUser;

  const Authenticated(this.currentUser);

  @override
  List<Object> get props => [currentUser];

  @override
  String toString() => 'Authenticated { username: ${currentUser.username} }';
}

class Unauthenticated extends AuthenticationState {}

/// 网络错误或者用户名密码错误
class AuthenticationFailure extends AuthenticationState {
  final String error;

  const AuthenticationFailure(
    this.error,
  );

  @override
  List<Object> get props => [error];

  @override
  String toString() => 'AuthenticationFailure { error: $error }';
}

/// 更严重的错误，需要有时需要重启软件（只发生在软件启动阶段）
class AuthenticationError extends AuthenticationState {
  final String error;

  const AuthenticationError(
    this.error,
  );

  @override
  List<Object> get props => [error];

  @override
  String toString() => 'AuthenticationError { error: $error }';
}
