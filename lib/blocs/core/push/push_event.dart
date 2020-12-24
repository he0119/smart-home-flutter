part of 'push_bloc.dart';

abstract class PushEvent extends Equatable {
  const PushEvent();

  @override
  List<Object> get props => [];
}

class PushStarted extends PushEvent {}

class PushUpdated extends PushEvent {
  final MiPush miPush;

  PushUpdated({@required this.miPush});

  @override
  List<Object> get props => [miPush];

  @override
  String toString() => 'PushUpdated { regId: ${miPush.regId} }';
}

class PushRefreshed extends PushEvent {}
