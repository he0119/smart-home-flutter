part of 'push_bloc.dart';

abstract class PushEvent extends Equatable {
  const PushEvent();

  @override
  List<Object> get props => [];
}

class PushStarted extends PushEvent {}

class PushUpdated extends PushEvent {}
