import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/storage/model/storage.dart';
import 'package:smarthome/utils/exceptions.dart';

/// Item detail state
class ItemDetailState {
  final ItemDetailStatus status;
  final String errorMessage;
  final Item item;

  const ItemDetailState({
    this.status = ItemDetailStatus.initial,
    this.errorMessage = '',
    this.item = const Item(id: '', name: ''),
  });

  ItemDetailState copyWith({
    ItemDetailStatus? status,
    String? errorMessage,
    Item? item,
  }) {
    return ItemDetailState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      item: item ?? this.item,
    );
  }
}

enum ItemDetailStatus { initial, loading, success, failure }

/// Item detail notifier
class ItemDetailNotifier extends Notifier<ItemDetailState> {
  late String itemId;

  @override
  ItemDetailState build() {
    return const ItemDetailState();
  }

  void initialize(String id) {
    itemId = id;
    _loadItem(id);
  }

  Future<void> _loadItem(String id, {bool cache = true}) async {
    state = state.copyWith(status: ItemDetailStatus.loading);

    try {
      final storageRepository = ref.read(storageRepositoryProvider);
      final item = await storageRepository.item(id: id, cache: cache);

      if (item == null) {
        state = state.copyWith(
          status: ItemDetailStatus.failure,
          errorMessage: '获取物品失败，物品不存在',
        );
        return;
      }

      state = state.copyWith(status: ItemDetailStatus.success, item: item);
    } on MyException catch (e) {
      state = state.copyWith(
        status: ItemDetailStatus.failure,
        errorMessage: e.message,
      );
    }
  }

  Future<void> refresh() async {
    if (state.status == ItemDetailStatus.success) {
      await _loadItem(state.item.id, cache: false);
    }
  }
}

/// Item detail provider
/// Note: 由于需要传递 itemId，实际使用时需要在页面中创建独立的 provider
final itemDetailProvider =
    NotifierProvider<ItemDetailNotifier, ItemDetailState>(
      ItemDetailNotifier.new,
    );
