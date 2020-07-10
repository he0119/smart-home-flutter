part of 'authentication_bloc.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];
}

class AuthenticationStarted extends AuthenticationEvent {}

class AuthenticationLogin extends AuthenticationEvent {
  final String username;
  final String password;

  const AuthenticationLogin(this.username, this.password);

  @override
  List<Object> get props => [username, password];
}

class AuthenticationLogout extends AuthenticationEvent {}
