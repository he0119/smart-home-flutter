part of 'authentication_bloc.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object> get props => [];
}

class AppUninitialized extends AuthenticationState {}

class Authenticating extends AuthenticationState {}

class Authenticated extends AuthenticationState {
  final User currentUser;

  const Authenticated(this.currentUser);

  @override
  List<Object> get props => [currentUser];

  @override
  String toString() => 'Authenticated { username: ${currentUser.username} }';
}

class Unauthenticated extends AuthenticationState {
  final String message;

  const Unauthenticated(
    this.message,
  );

  @override
  List<Object> get props => [message];
}
