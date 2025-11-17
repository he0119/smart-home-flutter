import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/storage/model/storage.dart';
import 'package:smarthome/utils/exceptions.dart';

/// Picture notifier
class PictureNotifier extends AsyncNotifier<Picture> {
  PictureNotifier(this._pictureId);

  final String _pictureId;

  @override
  Future<Picture> build() async {
    return await _loadPicture(_pictureId);
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
    state = await AsyncValue.guard(
      () => _loadPicture(_pictureId, cache: false),
    );
  }
}

/// Picture provider
final pictureProvider =
    AsyncNotifierProvider.family<PictureNotifier, Picture, String>(
      PictureNotifier.new,
    );
