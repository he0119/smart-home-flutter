import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/storage/model/storage.dart';
import 'package:smarthome/utils/exceptions.dart';

part 'item_edit_provider.g.dart';

/// Item edit state
class ItemEditState {
  final ItemEditStatus status;
  final String errorMessage;
  final Item? item;

  const ItemEditState({
    this.status = ItemEditStatus.initial,
    this.errorMessage = '',
    this.item,
  });

  ItemEditState copyWith({
    ItemEditStatus? status,
    String? errorMessage,
    Item? item,
  }) {
    return ItemEditState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      item: item ?? this.item,
    );
  }

  @override
  String toString() {
    return 'ItemEditState(status: $status, item: ${item?.name})';
  }
}

enum ItemEditStatus {
  initial,
  loading,
  addSuccess,
  updateSuccess,
  deleteSuccess,
  restoreSuccess,
  consumableAddSuccess,
  consumableDeleteSuccess,
  failure,
}

/// Item edit notifier
@riverpod
class ItemEdit extends _$ItemEdit {
  @override
  ItemEditState build() {
    return const ItemEditState();
  }

  Future<void> addItem({
    required String name,
    required int number,
    String? storageId,
    String? description,
    double? price,
    DateTime? expiredAt,
  }) async {
    state = state.copyWith(status: ItemEditStatus.loading);

    try {
      final storageRepository = ref.read(storageRepositoryProvider);
      final item = await storageRepository.addItem(
        name: name,
        number: number,
        storageId: storageId,
        description: description,
        price: price,
        expiredAt: expiredAt,
      );
      state = state.copyWith(status: ItemEditStatus.addSuccess, item: item);
    } on MyException catch (e) {
      state = state.copyWith(
        status: ItemEditStatus.failure,
        errorMessage: e.message,
      );
    }
  }

  Future<void> updateItem({
    required String id,
    required String name,
    required int number,
    String? storageId,
    String? description,
    double? price,
    DateTime? expiredAt,
  }) async {
    state = state.copyWith(status: ItemEditStatus.loading);

    try {
      final storageRepository = ref.read(storageRepositoryProvider);
      final item = await storageRepository.updateItem(
        id: id,
        name: name,
        number: number,
        storageId: storageId,
        description: description,
        price: price,
        expiredAt: expiredAt,
      );
      state = state.copyWith(status: ItemEditStatus.updateSuccess, item: item);
    } on MyException catch (e) {
      state = state.copyWith(
        status: ItemEditStatus.failure,
        errorMessage: e.message,
      );
    }
  }

  Future<void> deleteItem(Item item) async {
    state = state.copyWith(status: ItemEditStatus.loading);

    try {
      final storageRepository = ref.read(storageRepositoryProvider);
      await storageRepository.deleteItem(itemId: item.id);
      state = state.copyWith(status: ItemEditStatus.deleteSuccess, item: item);
    } on MyException catch (e) {
      state = state.copyWith(
        status: ItemEditStatus.failure,
        errorMessage: e.message,
      );
    }
  }

  Future<void> restoreItem(Item item) async {
    state = state.copyWith(status: ItemEditStatus.loading);

    try {
      final storageRepository = ref.read(storageRepositoryProvider);
      await storageRepository.restoreItem(itemId: item.id);
      state = state.copyWith(status: ItemEditStatus.restoreSuccess, item: item);
    } on MyException catch (e) {
      state = state.copyWith(
        status: ItemEditStatus.failure,
        errorMessage: e.message,
      );
    }
  }

  Future<void> addConsumable({
    required Item item,
    required List<Item?> consumables,
  }) async {
    state = state.copyWith(status: ItemEditStatus.loading);

    try {
      final storageRepository = ref.read(storageRepositoryProvider);
      final updatedItem = await storageRepository.addConsumable(
        id: item.id,
        consumableIds: consumables.map((e) => e!.id).toList(),
      );
      state = state.copyWith(
        status: ItemEditStatus.consumableAddSuccess,
        item: updatedItem,
      );
    } on MyException catch (e) {
      state = state.copyWith(
        status: ItemEditStatus.failure,
        errorMessage: e.message,
      );
    }
  }

  Future<void> deleteConsumable({
    required Item item,
    required List<Item> consumables,
  }) async {
    state = state.copyWith(status: ItemEditStatus.loading);

    try {
      final storageRepository = ref.read(storageRepositoryProvider);
      final updatedItem = await storageRepository.deleteConsumable(
        id: item.id,
        consumableIds: consumables.map((e) => e.id).toList(),
      );
      state = state.copyWith(
        status: ItemEditStatus.consumableDeleteSuccess,
        item: updatedItem,
      );
    } on MyException catch (e) {
      state = state.copyWith(
        status: ItemEditStatus.failure,
        errorMessage: e.message,
      );
    }
  }

  void reset() {
    state = const ItemEditState();
  }
}
