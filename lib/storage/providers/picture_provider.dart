import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/storage/model/storage.dart';
import 'package:smarthome/utils/exceptions.dart';

part 'picture_provider.g.dart';

/// Picture notifier
@riverpod
class PictureNotifier extends _$PictureNotifier {
  @override
  Future<Picture> build(String pictureId) async {
    return await _loadPicture(pictureId);
  }

  Future<Picture> _loadPicture(String id, {bool cache = true}) async {
    try {
      final storageRepository = ref.read(storageRepositoryProvider);
      final picture = await storageRepository.picture(id: id, cache: cache);

      if (picture == null) {
        throw MyException('获取图片失败，图片不存在');
      }

      return picture;
    } on MyException {
      rethrow;
    } catch (e) {
      throw MyException('获取图片失败: $e');
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadPicture(pictureId, cache: false));
  }
}
