part of 'topic_edit_bloc.dart';

abstract class TopicEditState extends Equatable {
  const TopicEditState();

  @override
  List<Object> get props => [];
}

class TopicInProgress extends TopicEditState {
  @override
  String toString() => 'TopicInProgress';
}

class TopicFailure extends TopicEditState {
  final String message;

  const TopicFailure(this.message);

  @override
  List<Object> get props => [message];

  @override
  String toString() => 'TopicFailure(message: $message)';
}

class TopicAddSuccess extends TopicEditState {
  final Topic topic;

  const TopicAddSuccess({required this.topic});

  @override
  List<Object> get props => [topic];

  @override
  String toString() => 'TopicAddSuccess(topic: $topic)';
}

class TopicUpdateSuccess extends TopicEditState {
  final Topic topic;

  const TopicUpdateSuccess({required this.topic});

  @override
  List<Object> get props => [topic];

  @override
  String toString() => 'TopicUpdateSuccess(topic: $topic)';
}

class TopicDeleteSuccess extends TopicEditState {
  final Topic topic;

  const TopicDeleteSuccess({required this.topic});

  @override
  List<Object> get props => [topic];

  @override
  String toString() => 'TopicDeleteSuccess(topic: $topic)';
}

class TopicPinSuccess extends TopicEditState {
  final Topic topic;

  const TopicPinSuccess({required this.topic});

  @override
  List<Object> get props => [topic];

  @override
  String toString() => 'TopicPinSuccess(topic: $topic)';
}

class TopicUnpinSuccess extends TopicEditState {
  final Topic topic;

  const TopicUnpinSuccess({required this.topic});

  @override
  List<Object> get props => [topic];

  @override
  String toString() => 'TopicUnpinSuccess(topic: $topic)';
}

class TopicCloseSuccess extends TopicEditState {
  final Topic topic;

  const TopicCloseSuccess({required this.topic});

  @override
  List<Object> get props => [topic];

  @override
  String toString() => 'TopicCloseSuccess(topic: $topic)';
}

class TopicReopenSuccess extends TopicEditState {
  final Topic topic;

  const TopicReopenSuccess({required this.topic});

  @override
  List<Object> get props => [topic];

  @override
  String toString() => 'TopicReopenSuccess(topic: $topic)';
}
