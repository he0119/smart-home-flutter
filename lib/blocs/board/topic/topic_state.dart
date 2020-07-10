part of 'topic_bloc.dart';

abstract class TopicState extends Equatable {
  const TopicState();

  @override
  List<Object> get props => [];
}

class TopicInitial extends TopicState {}

class TopicInProgress extends TopicState {}

class TopicAddSuccess extends TopicState {
  final Topic topic;

  const TopicAddSuccess({@required this.topic});

  @override
  List<Object> get props => [topic];
}

class TopicUpdateSuccess extends TopicState {
  final Topic topic;

  const TopicUpdateSuccess({@required this.topic});

  @override
  List<Object> get props => [topic];
}

class TopicDeleteSuccess extends TopicState {
  final Topic topic;

  const TopicDeleteSuccess({@required this.topic});

  @override
  List<Object> get props => [topic];
}

class TopicError extends TopicState {
  final String message;

  const TopicError({@required this.message});

  @override
  List<Object> get props => [message];

  @override
  String toString() {
    return 'TopicError { $message }';
  }
}
