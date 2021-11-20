part of 'authentication_bloc.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object> get props => [];
}

class AuthenticationInitial extends AuthenticationState {
  @override
  String toString() => 'AuthenticationInitial';
}

class AuthenticationInProgress extends AuthenticationState {
  @override
  String toString() => 'AuthenticationInProgress';
}

/// 登陆成功
class AuthenticationSuccess extends AuthenticationState {
  final User currentUser;

  const AuthenticationSuccess(this.currentUser);

  @override
  List<Object> get props => [currentUser];

  @override
  String toString() => 'AuthenticationSuccess(currentUser: $currentUser)';
}

/// 登陆失败
///
/// 用户名密码错误
class AuthenticationFailure extends AuthenticationState {
  final String message;

  const AuthenticationFailure(this.message);

  @override
  List<Object> get props => [message];

  @override
  String toString() => 'AuthenticationFailure(message: $message)';
}

/// 网络错误
class AuthenticationError extends AuthenticationState {
  final String message;

  const AuthenticationError(this.message);

  @override
  List<Object> get props => [message];

  @override
  String toString() => 'AuthenticationError(message: $message)';
}
