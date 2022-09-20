part of 'session_bloc.dart';

abstract class SessionState extends Equatable {
  const SessionState();

  @override
  List<Object> get props => [];
}

class SessionInProgress extends SessionState {
  @override
  String toString() => 'SessionInProgress';
}

class SessionFailure extends SessionState {
  final String message;

  const SessionFailure(this.message);

  @override
  List<Object> get props => [message];

  @override
  String toString() => 'SessionFailure(message: $message)';
}

class SessionSuccess extends SessionState {
  final List<Session> sessions;

  const SessionSuccess({
    required this.sessions,
  });

  @override
  List<Object> get props => [sessions];

  @override
  String toString() => 'SessionSuccess(sessions: ${sessions.length})';
}
