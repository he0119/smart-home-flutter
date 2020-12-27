part of 'topic_detail_bloc.dart';

abstract class TopicDetailEvent extends Equatable {
  const TopicDetailEvent();

  @override
  List<Object> get props => [];
}

class TopicDetailFetched extends TopicDetailEvent {
  final String topicId;
  final bool descending;
  final bool refresh;

  const TopicDetailFetched({
    @required this.topicId,
    @required this.descending,
    this.refresh = false,
  });

  @override
  List<Object> get props => [topicId, descending, refresh];

  @override
  String toString() =>
      'TopicDetailFetched(topicId: $topicId, descending: $descending, refresh: $refresh)';
}
