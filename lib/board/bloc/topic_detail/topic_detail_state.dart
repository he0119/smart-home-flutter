part of 'topic_detail_bloc.dart';

class TopicDetailState extends Equatable {
  /// 当前状态
  final TopicDetailStatus status;

  /// 错误信息
  final String error;

  /// 位置页面所需数据
  final Topic topic;
  final List<Comment> comments;
  final PageInfo pageInfo;

  const TopicDetailState({
    this.status = TopicDetailStatus.initial,
    this.error = '',
    // 初始为空值
    this.topic = const Topic(id: ''),
    this.comments = const [],
    this.pageInfo = const PageInfo(hasNextPage: false),
  });

  bool get hasReachedMax => !pageInfo.hasNextPage;

  @override
  List<Object?> get props => [status, error, topic, comments, pageInfo];

  @override
  bool get stringify => true;

  TopicDetailState copyWith({
    TopicDetailStatus? status,
    String? error,
    Topic? topic,
    List<Comment>? comments,
    PageInfo? pageInfo,
  }) {
    return TopicDetailState(
      status: status ?? this.status,
      error: error ?? this.error,
      topic: topic ?? this.topic,
      comments: comments ?? this.comments,
      pageInfo: pageInfo ?? this.pageInfo,
    );
  }
}
