part of 'push_bloc.dart';

abstract class PushState extends Equatable {
  const PushState();

  @override
  List<Object> get props => [];
}

class PushInitial extends PushState {}

class PushInProgress extends PushState {}

class PushSuccess extends PushState {}
