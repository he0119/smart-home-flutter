part of 'board_home_bloc.dart';

abstract class BoardHomeState extends Equatable {
  const BoardHomeState();

  @override
  List<Object> get props => [];
}

class BoardHomeInitial extends BoardHomeState {}

class BoardHomeInProgress extends BoardHomeState {}

class BoardHomeError extends BoardHomeState {
  final String message;

  const BoardHomeError({@required this.message});

  @override
  List<Object> get props => [message];
}

class BoardHomeSuccess extends BoardHomeState {
  final List<Topic> topics;

  const BoardHomeSuccess({
    this.topics,
  });

  @override
  List<Object> get props => [topics];

  @override
  String toString() => 'BoardHomeSuccess { topics ${topics?.length ?? 0} }';
}
