part of 'board_home_bloc.dart';

abstract class BoardHomeState extends Equatable {
  const BoardHomeState();

  @override
  List<Object> get props => [];
}

class BoardHomeInProgress extends BoardHomeState {
  @override
  String toString() => 'BoardHomeInProgress';
}

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
  final PageInfo pageInfo;

  const BoardHomeSuccess({
    required this.topics,
    required this.pageInfo,
  });

  bool get hasReachedMax => !pageInfo.hasNextPage;

  @override
  List<Object> get props => [topics, pageInfo];

  @override
  String toString() =>
      'BoardHomeSuccess { topics: ${topics.length}, hasReachedMax: $hasReachedMax';
}
