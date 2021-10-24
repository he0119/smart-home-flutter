part of 'push_bloc.dart';

abstract class PushEvent extends Equatable {
  const PushEvent();

  @override
  List<Object> get props => [];
}

class PushStarted extends PushEvent {
  @override
  String toString() => 'PushStarted';
}

class PushUpdated extends PushEvent {
  final MiPush miPush;

  const PushUpdated({required this.miPush});

  @override
  List<Object> get props => [miPush];

  @override
  String toString() => 'PushUpdated(miPush: $miPush)';
}

class PushRefreshed extends PushEvent {
  @override
  String toString() => 'PushRefreshed';
}
