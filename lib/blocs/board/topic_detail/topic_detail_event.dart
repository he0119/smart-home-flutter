part of 'topic_detail_bloc.dart';

abstract class TopicDetailEvent extends Equatable {
  const TopicDetailEvent();

  @override
  List<Object> get props => [];
}

class TopicDetailChanged extends TopicDetailEvent {
  final String topicId;
  final bool descending;

  const TopicDetailChanged({
    @required this.topicId,
    @required this.descending,
  });

  @override
  String toString() =>
      'TopicChanged { TopicId: $topicId, descending: $descending }';
}

class TopicDetailRefreshed extends TopicDetailEvent {
  const TopicDetailRefreshed();

  @override
  String toString() => 'TopicRefreshed';
}
