import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/storage/model/storage.dart';
import 'package:smarthome/storage/repository/storage_repository.dart';
import 'package:smarthome/utils/exceptions.dart';
import 'package:tuple/tuple.dart';

part 'item_type_items_provider.g.dart';

class ItemTypeItemsState {
  final ItemTypeItemsStatus status;
  final String errorMessage;
  final List<Item> items;
  final PageInfo pageInfo;

  const ItemTypeItemsState({
    this.status = ItemTypeItemsStatus.initial,
    this.errorMessage = '',
    this.items = const <Item>[],
    this.pageInfo = const PageInfo(hasNextPage: false),
  });

  bool get hasReachedMax => !pageInfo.hasNextPage;

  ItemTypeItemsState copyWith({
    ItemTypeItemsStatus? status,
    String? errorMessage,
    List<Item>? items,
    PageInfo? pageInfo,
  }) {
    return ItemTypeItemsState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      items: items ?? this.items,
      pageInfo: pageInfo ?? this.pageInfo,
    );
  }
}

enum ItemTypeItemsStatus { initial, loading, success, failure }

/// 某一类物品的完整列表（首页分组点「全部」进来）
@riverpod
class ItemTypeItems extends _$ItemTypeItems {
  bool _fetchingMore = false;

  @override
  ItemTypeItemsState build(ItemType type) {
    Future.microtask(() => fetch(cache: true));
    return const ItemTypeItemsState();
  }

  Future<void> fetch({bool cache = true}) async {
    final repository = ref.read(storageRepositoryProvider);
    try {
      if (!cache || state.status != ItemTypeItemsStatus.success) {
        state = state.copyWith(
          status: ItemTypeItemsStatus.loading,
          errorMessage: '',
        );
      }
      final page = await _fetchPage(repository, cache: cache);
      if (!ref.mounted) return;
      state = ItemTypeItemsState(
        status: ItemTypeItemsStatus.success,
        items: page.item1,
        pageInfo: page.item2,
      );
    } on MyException catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        status: ItemTypeItemsStatus.failure,
        errorMessage: e.message,
      );
    }
  }

  Future<void> fetchMore() async {
    if (_fetchingMore ||
        state.status != ItemTypeItemsStatus.success ||
        state.hasReachedMax) {
      return;
    }
    _fetchingMore = true;
    try {
      final repository = ref.read(storageRepositoryProvider);
      final page = await _fetchPage(
        repository,
        cache: false,
        after: state.pageInfo.endCursor,
      );
      if (!ref.mounted) return;
      state = state.copyWith(
        items: <Item>[...state.items, ...page.item1],
        pageInfo: state.pageInfo.copyWith(page.item2),
      );
    } on MyException catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        status: ItemTypeItemsStatus.failure,
        errorMessage: e.message,
      );
    } finally {
      _fetchingMore = false;
    }
  }

  Future<Tuple2<List<Item>, PageInfo>> _fetchPage(
    StorageRepository repository, {
    required bool cache,
    String? after,
  }) {
    return switch (type) {
      ItemType.expired => repository.expiredItems(after: after, cache: cache),
      ItemType.nearExpired => repository.nearExpiredItems(
        after: after,
        cache: cache,
      ),
      ItemType.recentlyCreated => repository.recentlyCreatedItems(
        after: after,
        cache: cache,
      ),
      ItemType.recentlyEdited => repository.recentlyEditedItems(
        after: after,
        cache: cache,
      ),
      ItemType.all => throw UnimplementedError('ItemType.all 没有单独的列表'),
    };
  }
}
