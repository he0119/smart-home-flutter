part of 'topic_detail_bloc.dart';

abstract class TopicDetailState extends Equatable {
  const TopicDetailState();

  @override
  List<Object> get props => [];
}

class TopicDetailInProgress extends TopicDetailState {
  @override
  String toString() => 'TopicDetailInProgress';
}

class TopicDetailFailure extends TopicDetailState {
  final String message;
  final String topicId;

  const TopicDetailFailure(
    this.message, {
    required this.topicId,
  });

  @override
  List<Object> get props => [message, topicId];

  @override
  String toString() => 'TopicDetailFailure { message: $message }';
}

class TopicDetailSuccess extends TopicDetailState {
  final Topic topic;
  final List<Comment> comments;
  final PageInfo pageInfo;

  const TopicDetailSuccess({
    required this.topic,
    required this.comments,
    required this.pageInfo,
  });

  bool get hasReachedMax => !pageInfo.hasNextPage;

  @override
  List<Object> get props => [topic, comments, pageInfo];

  @override
  String toString() => 'TopicDetailSuccess(topic: $topic, comments: $comments)';
}
