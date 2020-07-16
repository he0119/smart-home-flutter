part of 'topic_detail_bloc.dart';

abstract class TopicDetailState extends Equatable {
  const TopicDetailState();

  @override
  List<Object> get props => [];
}

class TopicDetailInProgress extends TopicDetailState {}

class TopicDetailFailure extends TopicDetailState {
  final String message;
  final String topicId;

  const TopicDetailFailure(
    this.message, {
    @required this.topicId,
  });

  @override
  String toString() => 'TopicDetailFailure { message: $message }';
}

class TopicDetailSuccess extends TopicDetailState {
  final Topic topic;
  final List<Comment> comments;

  const TopicDetailSuccess({@required this.topic, @required this.comments});

  @override
  String toString() =>
      'TopicDetailSuccess { Topic: ${topic.title}, Comments: ${comments.length} }';
}
