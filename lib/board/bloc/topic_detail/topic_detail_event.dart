part of 'topic_detail_bloc.dart';

abstract class TopicDetailEvent extends Equatable {
  const TopicDetailEvent();

  @override
  List<Object?> get props => [];
}

class TopicDetailFetched extends TopicDetailEvent {
  final String? topicId;
  final bool descending;
  final bool cache;
  final bool showInProgress;

  const TopicDetailFetched({
    this.topicId,
    required this.descending,
    this.cache = true,
    this.showInProgress = true,
  });

  @override
  List<Object?> get props => [topicId, descending, cache, showInProgress];

  @override
  String toString() =>
      'TopicDetailFetched(topicId: $topicId, descending: $descending)';
}
