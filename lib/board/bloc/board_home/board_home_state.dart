part of 'board_home_bloc.dart';

class BoardHomeState extends Equatable {
  /// 当前状态
  final BoardHomeStatus status;

  /// 错误信息
  final String error;

  /// 位置页面所需数据
  final List<Topic> topics;
  final PageInfo pageInfo;

  const BoardHomeState({
    this.status = BoardHomeStatus.initial,
    this.error = '',
    // 初始为空值
    this.topics = const [],
    this.pageInfo = const PageInfo(hasNextPage: false),
  });

  bool get hasReachedMax => !pageInfo.hasNextPage;

  @override
  List<Object?> get props => [status, error, topics, pageInfo];

  @override
  bool get stringify => true;

  BoardHomeState copyWith({
    BoardHomeStatus? status,
    String? error,
    List<Topic>? topics,
    PageInfo? pageInfo,
  }) {
    return BoardHomeState(
      status: status ?? this.status,
      error: error ?? this.error,
      topics: topics ?? this.topics,
      pageInfo: pageInfo ?? this.pageInfo,
    );
  }
}
