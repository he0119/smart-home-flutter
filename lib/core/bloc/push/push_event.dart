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
  final String regId;

  const PushUpdated({required this.regId});

  @override
  List<Object> get props => [regId];

  @override
  String toString() => 'PushUpdated(regId: $regId)';
}

class PushRefreshed extends PushEvent {
  @override
  String toString() => 'PushRefreshed';
}
