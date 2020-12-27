part of 'topic_detail_bloc.dart';

abstract class TopicDetailEvent extends Equatable {
  const TopicDetailEvent();

  @override
  List<Object> get props => [];
}

class TopicDetailFetched extends TopicDetailEvent {
  final String topicId;
  final bool descending;
  final bool cache;

  const TopicDetailFetched({
    this.topicId,
    @required this.descending,
    this.cache = true,
  });

  @override
  List<Object> get props => [topicId, descending, cache];

  @override
  String toString() =>
      'TopicDetailFetched(topicId: $topicId, descending: $descending, cache: $cache)';
}
