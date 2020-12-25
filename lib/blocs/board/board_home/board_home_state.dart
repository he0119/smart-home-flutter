part of 'board_home_bloc.dart';

abstract class BoardHomeState extends Equatable {
  const BoardHomeState();

  @override
  List<Object> get props => [];
}

class BoardHomeInitial extends BoardHomeState {}

class BoardHomeFailure extends BoardHomeState {
  final String message;

  const BoardHomeFailure(this.message);

  @override
  List<Object> get props => [message];

  @override
  String toString() => 'BoardHomeFailure(message: $message)';
}

class BoardHomeSuccess extends BoardHomeState {
  final List<Topic> topics;
  final bool hasReachedMax;
  final String topicsEndCursor;

  const BoardHomeSuccess({
    this.topics,
    this.hasReachedMax,
    this.topicsEndCursor,
  });

  @override
  List<Object> get props => [topics, hasReachedMax, topicsEndCursor];

  @override
  String toString() =>
      'BoardHomeSuccess { topics: ${topics.length}, hasReachedMax: $hasReachedMax';
}
