import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/storage/model/storage.dart';
import 'package:smarthome/storage/repository/storage_repository.dart';
import 'package:smarthome/utils/exceptions.dart';

/// Storage home state
class StorageHomeState {
  final StorageHomeStatus status;
  final String errorMessage;
  final ItemType itemType;
  final List<Item>? recentlyCreatedItems;
  final List<Item>? recentlyEditedItems;
  final List<Item>? expiredItems;
  final List<Item>? nearExpiredItems;
  final PageInfo pageInfo;

  const StorageHomeState({
    this.status = StorageHomeStatus.initial,
    this.errorMessage = '',
    required this.itemType,
    this.recentlyCreatedItems,
    this.recentlyEditedItems,
    this.expiredItems,
    this.nearExpiredItems,
    this.pageInfo = const PageInfo(hasNextPage: false),
  });

  bool get hasReachedMax => !pageInfo.hasNextPage;

  int get itemCount {
    var count = 0;
    if (recentlyCreatedItems != null) count += recentlyCreatedItems!.length;
    if (recentlyEditedItems != null) count += recentlyEditedItems!.length;
    if (expiredItems != null) count += expiredItems!.length;
    if (nearExpiredItems != null) count += nearExpiredItems!.length;
    return count;
  }

  StorageHomeState copyWith({
    StorageHomeStatus? status,
    String? errorMessage,
    ItemType? itemType,
    List<Item>? Function()? recentlyCreatedItems,
    List<Item>? Function()? recentlyEditedItems,
    List<Item>? Function()? expiredItems,
    List<Item>? Function()? nearExpiredItems,
    PageInfo? pageInfo,
  }) {
    return StorageHomeState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      itemType: itemType ?? this.itemType,
      recentlyCreatedItems: recentlyCreatedItems != null
          ? recentlyCreatedItems()
          : this.recentlyCreatedItems,
      recentlyEditedItems: recentlyEditedItems != null
          ? recentlyEditedItems()
          : this.recentlyEditedItems,
      expiredItems: expiredItems != null ? expiredItems() : this.expiredItems,
      nearExpiredItems: nearExpiredItems != null
          ? nearExpiredItems()
          : this.nearExpiredItems,
      pageInfo: pageInfo ?? this.pageInfo,
    );
  }
}

enum StorageHomeStatus { initial, loading, success, failure }

/// Storage home notifier
class StorageHomeNotifier extends Notifier<StorageHomeState> {
  @override
  StorageHomeState build() {
    // 初始加载
    fetch(itemType: ItemType.all, cache: true);
    return const StorageHomeState(itemType: ItemType.all);
  }

  Future<void> fetch({required ItemType itemType, bool cache = true}) async {
    final storageRepository = ref.read(storageRepositoryProvider);

    try {
      // 如果需要刷新，或者切换了物品种类，则显示加载界面
      if (!cache || state.itemType != itemType) {
        state = state.copyWith(
          status: StorageHomeStatus.loading,
          itemType: itemType,
        );
      }

      if (cache &&
          state.status == StorageHomeStatus.success &&
          itemType == state.itemType &&
          !state.hasReachedMax) {
        // 如果不需要刷新，不是首次启动，并且有下一页，则获取下一页
        await _fetchNextPage(storageRepository, itemType);
      } else {
        // 其他情况根据设置看是否需要打开缓存，并获取第一页
        await _fetchFirstPage(storageRepository, itemType, cache);
      }
    } on MyException catch (e) {
      state = state.copyWith(
        status: StorageHomeStatus.failure,
        errorMessage: e.message,
        itemType: itemType,
      );
    }
  }

  Future<void> _fetchNextPage(
    StorageRepository storageRepository,
    ItemType itemType,
  ) async {
    switch (itemType) {
      case ItemType.expired:
        final results = await storageRepository.expiredItems(
          after: state.pageInfo.endCursor,
          cache: false,
        );
        state = state.copyWith(
          status: StorageHomeStatus.success,
          expiredItems: () => (state.expiredItems ?? []) + results.item1,
          pageInfo: state.pageInfo.copyWith(results.item2),
        );
        break;
      case ItemType.nearExpired:
        final results = await storageRepository.nearExpiredItems(
          after: state.pageInfo.endCursor,
          cache: false,
        );
        state = state.copyWith(
          status: StorageHomeStatus.success,
          nearExpiredItems: () =>
              (state.nearExpiredItems ?? []) + results.item1,
          pageInfo: state.pageInfo.copyWith(results.item2),
        );
        break;
      case ItemType.recentlyCreated:
        final results = await storageRepository.recentlyCreatedItems(
          after: state.pageInfo.endCursor,
          cache: false,
        );
        state = state.copyWith(
          status: StorageHomeStatus.success,
          recentlyCreatedItems: () =>
              (state.recentlyCreatedItems ?? []) + results.item1,
          pageInfo: state.pageInfo.copyWith(results.item2),
        );
        break;
      case ItemType.recentlyEdited:
        final results = await storageRepository.recentlyEditedItems(
          after: state.pageInfo.endCursor,
          cache: false,
        );
        state = state.copyWith(
          status: StorageHomeStatus.success,
          recentlyEditedItems: () =>
              (state.recentlyEditedItems ?? []) + results.item1,
          pageInfo: state.pageInfo.copyWith(results.item2),
        );
        break;
      case ItemType.all:
        break;
    }
  }

  Future<void> _fetchFirstPage(
    StorageRepository storageRepository,
    ItemType itemType,
    bool cache,
  ) async {
    switch (itemType) {
      case ItemType.expired:
        final results = await storageRepository.expiredItems(cache: cache);
        state = state.copyWith(
          status: StorageHomeStatus.success,
          expiredItems: () => results.item1,
          pageInfo: results.item2,
          itemType: ItemType.expired,
        );
        break;
      case ItemType.nearExpired:
        final results = await storageRepository.nearExpiredItems(cache: cache);
        state = state.copyWith(
          status: StorageHomeStatus.success,
          nearExpiredItems: () => results.item1,
          pageInfo: results.item2,
          itemType: ItemType.nearExpired,
        );
        break;
      case ItemType.recentlyCreated:
        final results = await storageRepository.recentlyCreatedItems(
          cache: cache,
        );
        state = state.copyWith(
          status: StorageHomeStatus.success,
          recentlyCreatedItems: () => results.item1,
          pageInfo: results.item2,
          itemType: ItemType.recentlyCreated,
        );
        break;
      case ItemType.recentlyEdited:
        final results = await storageRepository.recentlyEditedItems(
          cache: cache,
        );
        state = state.copyWith(
          status: StorageHomeStatus.success,
          recentlyEditedItems: () => results.item1,
          pageInfo: results.item2,
          itemType: ItemType.recentlyEdited,
        );
        break;
      case ItemType.all:
        final homepage = await storageRepository.homePage(cache: cache);
        state = state.copyWith(
          status: StorageHomeStatus.success,
          recentlyCreatedItems: () => homepage['recentlyCreatedItems'],
          recentlyEditedItems: () => homepage['recentlyEditedItems'],
          expiredItems: () => homepage['expiredItems'],
          nearExpiredItems: () => homepage['nearExpiredItems'],
          itemType: ItemType.all,
          pageInfo: const PageInfo(hasNextPage: false),
        );
        break;
    }
  }
}

/// Storage home provider
final storageHomeProvider =
    NotifierProvider<StorageHomeNotifier, StorageHomeState>(
      StorageHomeNotifier.new,
    );
