import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/storage/model/storage.dart';
import 'package:smarthome/utils/exceptions.dart';

/// Item detail notifier
class ItemDetailNotifier extends AsyncNotifier<Item> {
  ItemDetailNotifier(this._itemId);

  final String _itemId;

  @override
  Future<Item> build() async {
    return await _loadItem(_itemId);
  }

  Future<Item> _loadItem(String id, {bool cache = true}) async {
    try {
      final storageRepository = ref.read(storageRepositoryProvider);
      final item = await storageRepository.item(id: id, cache: cache);

      if (item == null) {
        throw MyException('获取物品失败，物品不存在');
      }

      return item;
    } on MyException {
      rethrow;
    } catch (e) {
      throw MyException('获取物品失败: $e');
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadItem(_itemId, cache: false));
  }
}

/// Item detail provider
final itemDetailProvider =
    AsyncNotifierProvider.family<ItemDetailNotifier, Item, String>(
      ItemDetailNotifier.new,
    );
