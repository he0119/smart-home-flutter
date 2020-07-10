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

/// 未登录
class Unauthenticated extends AuthenticationState {}

/// 用户名密码错误
class AuthenticationFailure extends AuthenticationState {
  final String message;

  const AuthenticationFailure(this.message);

  @override
  List<Object> get props => [message];

  @override
  String toString() => 'AuthenticationFailure { error: $message }';
}

/// 网络错误
class AuthenticationError extends AuthenticationState {
  final String message;

  const AuthenticationError(this.message);

  @override
  List<Object> get props => [message];

  @override
  String toString() => 'AuthenticationError { error: $message }';
}
