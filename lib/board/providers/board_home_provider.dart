import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/board/model/models.dart';
import 'package:smarthome/board/repository/board_repository.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/utils/exceptions.dart';

/// Board repository provider
final boardRepositoryProvider = Provider<BoardRepository>((ref) {
  final graphqlApiClient = ref.watch(graphQLApiClientProvider);
  return BoardRepository(graphqlApiClient: graphqlApiClient);
});

/// Board home state
class BoardHomeState {
  final BoardHomeStatus status;
  final String errorMessage;
  final List<Topic> topics;
  final PageInfo pageInfo;

  const BoardHomeState({
    this.status = BoardHomeStatus.initial,
    this.errorMessage = '',
    this.topics = const [],
    this.pageInfo = const PageInfo(hasNextPage: false),
  });

  bool get hasReachedMax => !pageInfo.hasNextPage;

  BoardHomeState copyWith({
    BoardHomeStatus? status,
    String? errorMessage,
    List<Topic>? topics,
    PageInfo? pageInfo,
  }) {
    return BoardHomeState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      topics: topics ?? this.topics,
      pageInfo: pageInfo ?? this.pageInfo,
    );
  }

  @override
  String toString() {
    return 'BoardHomeState(status: $status, topics: ${topics.length}, pageInfo: $pageInfo)';
  }
}

enum BoardHomeStatus { initial, loading, success, failure }

/// Board home notifier
class BoardHomeNotifier extends Notifier<BoardHomeState> {
  @override
  BoardHomeState build() {
    // 初始加载 - 延迟执行避免在 build 期间访问 state
    Future.microtask(() => fetch(cache: true));
    return const BoardHomeState();
  }

  Future<void> fetch({bool cache = true}) async {
    final boardRepository = ref.read(boardRepositoryProvider);

    try {
      // 如果需要刷新，则显示加载界面
      if (!cache) {
        state = state.copyWith(status: BoardHomeStatus.loading);
      }

      if (cache &&
          state.status == BoardHomeStatus.success &&
          !state.hasReachedMax) {
        // 如果不需要刷新，不是首次启动，或遇到错误，并且有下一页，则获取下一页
        final results = await boardRepository.topics(
          after: state.pageInfo.endCursor,
          cache: false,
        );
        state = state.copyWith(
          status: BoardHomeStatus.success,
          topics: state.topics + results.item1,
          pageInfo: state.pageInfo.copyWith(results.item2),
        );
      } else {
        // 其他情况根据设置看是否需要打开缓存，并获取第一页
        final results = await boardRepository.topics(cache: cache);
        state = state.copyWith(
          status: BoardHomeStatus.success,
          topics: results.item1,
          pageInfo: results.item2,
        );
      }
    } on MyException catch (e) {
      state = state.copyWith(
        status: BoardHomeStatus.failure,
        errorMessage: e.message,
      );
    }
  }
}

/// Board home provider
final boardHomeProvider = NotifierProvider<BoardHomeNotifier, BoardHomeState>(
  BoardHomeNotifier.new,
);
