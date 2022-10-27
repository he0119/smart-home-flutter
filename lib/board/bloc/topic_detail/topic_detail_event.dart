part of 'topic_detail_bloc.dart';

abstract class TopicDetailEvent extends Equatable {
  const TopicDetailEvent();

  @override
  List<Object?> get props => [];
}

class TopicDetailFetched extends TopicDetailEvent {
  final String id;
  final bool descending;
  final bool cache;
  final bool showInProgress;

  const TopicDetailFetched({
    required this.id,
    required this.descending,
    this.cache = true,
    this.showInProgress = true,
  });

  @override
  List<Object?> get props => [id, descending, cache, showInProgress];

  @override
  String toString() => 'TopicDetailFetched(id: $id, descending: $descending)';
}
