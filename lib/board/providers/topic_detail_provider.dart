import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/board/model/board.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/utils/exceptions.dart';

/// Topic detail status
enum TopicDetailStatus { initial, loading, success, failure }

/// Topic detail state
class TopicDetailState {
  final TopicDetailStatus status;
  final String errorMessage;
  final Topic topic;
  final List<Comment> comments;
  final PageInfo pageInfo;

  const TopicDetailState({
    this.status = TopicDetailStatus.initial,
    this.errorMessage = '',
    this.topic = const Topic(id: '', title: ''),
    this.comments = const [],
    this.pageInfo = const PageInfo(hasNextPage: false),
  });

  bool get hasReachedMax => !pageInfo.hasNextPage;

  TopicDetailState copyWith({
    TopicDetailStatus? status,
    String? errorMessage,
    Topic? topic,
    List<Comment>? comments,
    PageInfo? pageInfo,
  }) {
    return TopicDetailState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      topic: topic ?? this.topic,
      comments: comments ?? this.comments,
      pageInfo: pageInfo ?? this.pageInfo,
    );
  }

  @override
  String toString() {
    return 'TopicDetailState(status: $status, topic: ${topic.title}, comments: ${comments.length}, pageInfo: $pageInfo)';
  }
}

/// Topic detail notifier
class TopicDetailNotifier extends Notifier<TopicDetailState> {
  TopicDetailNotifier(this._topicId);

  final String _topicId;
  bool _descending = true;

  @override
  TopicDetailState build() {
    // Will be initialized with descending parameter in the screen
    return const TopicDetailState();
  }

  /// Initialize with descending order and load data
  void initialize({bool descending = true}) {
    _descending = descending;
    _loadTopic(cache: true, showLoading: true);
  }

  /// Refresh topic data
  void refresh({bool descending = true}) {
    _descending = descending;
    _loadTopic(cache: false, showLoading: true);
  }

  /// Fetch more comments (pagination)
  Future<void> fetchMore({bool descending = true}) async {
    if (state.hasReachedMax || state.status == TopicDetailStatus.loading) {
      return;
    }

    _descending = descending;

    try {
      final boardRepository = ref.read(boardRepositoryProvider);
      final results = await boardRepository.topicDetail(
        topicId: state.topic.id,
        descending: _descending,
        after: state.pageInfo.endCursor,
        cache: false,
      );
      state = state.copyWith(
        status: TopicDetailStatus.success,
        topic: results.item1,
        comments: state.comments + results.item2,
        pageInfo: state.pageInfo.copyWith(results.item3),
      );
    } on MyException catch (e) {
      state = state.copyWith(
        status: TopicDetailStatus.failure,
        errorMessage: e.message,
      );
    }
  }

  Future<void> _loadTopic({
    required bool cache,
    required bool showLoading,
  }) async {
    if (showLoading) {
      state = state.copyWith(status: TopicDetailStatus.loading);
    }

    try {
      final boardRepository = ref.read(boardRepositoryProvider);
      final topicId = _topicId;

      final results = await boardRepository.topicDetail(
        topicId: topicId,
        descending: _descending,
        cache: cache,
      );

      state = state.copyWith(
        status: TopicDetailStatus.success,
        topic: results.item1,
        comments: results.item2,
        pageInfo: results.item3,
      );
    } on MyException catch (e) {
      state = state.copyWith(
        status: TopicDetailStatus.failure,
        errorMessage: e.message,
      );
    }
  }
}

/// Topic detail provider
final topicDetailProvider =
    NotifierProvider.family<TopicDetailNotifier, TopicDetailState, String>(
      TopicDetailNotifier.new,
    );
