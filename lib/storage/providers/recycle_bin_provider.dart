import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/storage/model/storage.dart';
import 'package:smarthome/utils/exceptions.dart';

/// RecycleBin state
class RecycleBinState {
  final RecycleBinStatus status;
  final String errorMessage;
  final List<Item> items;
  final PageInfo pageInfo;

  const RecycleBinState({
    this.status = RecycleBinStatus.initial,
    this.errorMessage = '',
    this.items = const [],
    this.pageInfo = const PageInfo(hasNextPage: false),
  });

  bool get hasReachedMax => !pageInfo.hasNextPage;

  RecycleBinState copyWith({
    RecycleBinStatus? status,
    String? errorMessage,
    List<Item>? items,
    PageInfo? pageInfo,
  }) {
    return RecycleBinState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      items: items ?? this.items,
      pageInfo: pageInfo ?? this.pageInfo,
    );
  }
}

enum RecycleBinStatus { initial, loading, success, failure }

/// RecycleBin notifier
class RecycleBinNotifier extends Notifier<RecycleBinState> {
  @override
  RecycleBinState build() {
    // 初始加载
    fetch(cache: true);
    return const RecycleBinState();
  }

  Future<void> fetch({bool cache = true}) async {
    final storageRepository = ref.read(storageRepositoryProvider);

    try {
      // 如果需要刷新，则显示加载界面
      if (!cache) {
        state = state.copyWith(status: RecycleBinStatus.loading);
      }

      if (cache &&
          state.status == RecycleBinStatus.success &&
          !state.hasReachedMax) {
        // 如果不需要刷新，不是首次启动，并且有下一页，则获取下一页
        final results = await storageRepository.deletedItems(
          after: state.pageInfo.endCursor,
          cache: false,
        );
        state = state.copyWith(
          status: RecycleBinStatus.success,
          items: state.items + results.item1,
          pageInfo: state.pageInfo.copyWith(results.item2),
        );
      } else {
        // 其他情况根据设置看是否需要打开缓存，并获取第一页
        final results = await storageRepository.deletedItems(cache: cache);
        state = state.copyWith(
          status: RecycleBinStatus.success,
          items: results.item1,
          pageInfo: results.item2,
        );
      }
    } on MyException catch (e) {
      state = state.copyWith(
        status: RecycleBinStatus.failure,
        errorMessage: e.message,
      );
    }
  }
}

/// RecycleBin provider
final recycleBinProvider =
    NotifierProvider<RecycleBinNotifier, RecycleBinState>(
      RecycleBinNotifier.new,
    );
