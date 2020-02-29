part of 'authentication_bloc.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];
}

class AppStarted extends AuthenticationEvent {}

class LogIn extends AuthenticationEvent {
  final String username;
  final String password;

  const LogIn(this.username, this.password);

  @override
  List<Object> get props => [username, password];
}

class LogOut extends AuthenticationEvent {}
