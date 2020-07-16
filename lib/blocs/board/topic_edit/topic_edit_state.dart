part of 'topic_edit_bloc.dart';

abstract class TopicEditState extends Equatable {
  const TopicEditState();

  @override
  List<Object> get props => [];
}

class TopicInitial extends TopicEditState {}

class TopicInProgress extends TopicEditState {}

class TopicFailure extends TopicEditState {
  final String message;

  const TopicFailure(this.message);

  @override
  List<Object> get props => [message];

  @override
  String toString() {
    return 'TopicFailure { $message }';
  }
}

class TopicAddSuccess extends TopicEditState {
  final Topic topic;

  const TopicAddSuccess({@required this.topic});

  @override
  List<Object> get props => [topic];
}

class TopicUpdateSuccess extends TopicEditState {
  final Topic topic;

  const TopicUpdateSuccess({@required this.topic});

  @override
  List<Object> get props => [topic];
}

class TopicDeleteSuccess extends TopicEditState {
  final Topic topic;

  const TopicDeleteSuccess({@required this.topic});

  @override
  List<Object> get props => [topic];
}
