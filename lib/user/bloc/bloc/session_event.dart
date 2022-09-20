part of 'session_bloc.dart';

abstract class SessionEvent extends Equatable {
  const SessionEvent();

  @override
  List<Object> get props => [];
}

class SessionFetched extends SessionEvent {
  @override
  String toString() => 'SessionFetched';
}

class SessionDeleted extends SessionEvent {
  final String id;

  const SessionDeleted(this.id);

  @override
  List<Object> get props => [id];

  @override
  String toString() => 'SessionDeleted(id: $id)';
}
