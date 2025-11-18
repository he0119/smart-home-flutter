import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/storage/model/storage.dart';
import 'package:smarthome/utils/exceptions.dart';

part 'item_detail_provider.g.dart';

/// Item detail notifier
@riverpod
class ItemDetail extends _$ItemDetail {
  @override
  Future<Item> build(String itemId) async {
    return await _loadItem(itemId);
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
    state = await AsyncValue.guard(() => _loadItem(itemId, cache: false));
  }
}
