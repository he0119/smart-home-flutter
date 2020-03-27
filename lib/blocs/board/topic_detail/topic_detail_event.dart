part of 'topic_detail_bloc.dart';

abstract class TopicDetailEvent extends Equatable {
  const TopicDetailEvent();

  @override
  List<Object> get props => [];
}

class TopicDetailChanged extends TopicDetailEvent {
  final String topicId;

  const TopicDetailChanged({@required this.topicId});

  @override
  String toString() => 'TopicChanged { TopicId: $topicId }';
}

class TopicDetailRefreshed extends TopicDetailEvent {
  final String topicId;

  const TopicDetailRefreshed({@required this.topicId});

  @override
  String toString() => 'TopicRefreshed { TopicId: $topicId }';
}
