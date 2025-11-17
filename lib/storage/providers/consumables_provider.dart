import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/storage/model/storage.dart';
import 'package:smarthome/utils/exceptions.dart';

/// Consumables state
class ConsumablesState {
  final ConsumablesStatus status;
  final String errorMessage;
  final List<Item> items;
  final PageInfo pageInfo;

  const ConsumablesState({
    this.status = ConsumablesStatus.initial,
    this.errorMessage = '',
    this.items = const [],
    this.pageInfo = const PageInfo(hasNextPage: false),
  });

  bool get hasReachedMax => !pageInfo.hasNextPage;

  ConsumablesState copyWith({
    ConsumablesStatus? status,
    String? errorMessage,
    List<Item>? items,
    PageInfo? pageInfo,
  }) {
    return ConsumablesState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      items: items ?? this.items,
      pageInfo: pageInfo ?? this.pageInfo,
    );
  }

  @override
  String toString() {
    return 'ConsumablesState(status: $status, items: ${items.length}, pageInfo: $pageInfo)';
  }
}

enum ConsumablesStatus { initial, loading, success, failure }

/// Consumables notifier
class ConsumablesNotifier extends Notifier<ConsumablesState> {
  @override
  ConsumablesState build() {
    // 初始加载 - 延迟执行避免在 build 期间访问 state
    Future.microtask(() => fetch(cache: true));
    return const ConsumablesState();
  }

  Future<void> fetch({bool cache = true}) async {
    final storageRepository = ref.read(storageRepositoryProvider);

    try {
      // 如果需要刷新，则显示加载界面
      if (!cache) {
        state = state.copyWith(status: ConsumablesStatus.loading);
      }

      if (cache &&
          state.status == ConsumablesStatus.success &&
          !state.hasReachedMax) {
        // 如果不需要刷新，不是首次启动，并且有下一页，则获取下一页
        final results = await storageRepository.consumables(
          after: state.pageInfo.endCursor,
          cache: false,
        );
        state = state.copyWith(
          status: ConsumablesStatus.success,
          items: state.items + results.item1,
          pageInfo: state.pageInfo.copyWith(results.item2),
        );
      } else {
        // 其他情况根据设置看是否需要打开缓存，并获取第一页
        final results = await storageRepository.consumables(cache: cache);
        state = state.copyWith(
          status: ConsumablesStatus.success,
          items: results.item1,
          pageInfo: results.item2,
        );
      }
    } on MyException catch (e) {
      state = state.copyWith(
        status: ConsumablesStatus.failure,
        errorMessage: e.message,
      );
    }
  }
}

/// Consumables provider
final consumablesProvider =
    NotifierProvider<ConsumablesNotifier, ConsumablesState>(
      ConsumablesNotifier.new,
    );
