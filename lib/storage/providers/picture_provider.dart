import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/storage/model/storage.dart';
import 'package:smarthome/utils/exceptions.dart';

/// Picture status
enum PictureStatus { initial, loading, success, failure }

/// Picture state
class PictureState {
  final PictureStatus status;
  final String errorMessage;
  final Picture picture;

  const PictureState({
    this.status = PictureStatus.initial,
    this.errorMessage = '',
    this.picture = const Picture(id: '', url: '', description: ''),
  });

  PictureState copyWith({
    PictureStatus? status,
    String? errorMessage,
    Picture? picture,
  }) {
    return PictureState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      picture: picture ?? this.picture,
    );
  }

  @override
  String toString() {
    return 'PictureState(status: $status, picture: ${picture.id})';
  }
}

/// Picture notifier
class PictureNotifier extends Notifier<PictureState> {
  late String _pictureId;

  @override
  PictureState build() {
    return const PictureState();
  }

  /// Initialize with picture ID and load data
  void initialize(String pictureId) {
    _pictureId = pictureId;
    _loadPicture(cache: true);
  }

  /// Refresh picture data
  void refresh() {
    _loadPicture(cache: false);
  }

  Future<void> _loadPicture({required bool cache}) async {
    state = state.copyWith(status: PictureStatus.loading);

    try {
      final storageRepository = ref.read(storageRepositoryProvider);
      final picture = await storageRepository.picture(
        id: _pictureId,
        cache: cache,
      );
      if (picture == null) {
        state = state.copyWith(
          status: PictureStatus.failure,
          errorMessage: '获取图片失败，图片不存在',
        );
        return;
      }
      state = state.copyWith(status: PictureStatus.success, picture: picture);
    } on MyException catch (e) {
      state = state.copyWith(
        status: PictureStatus.failure,
        errorMessage: e.message,
      );
    }
  }
}

/// Picture provider
final pictureProvider = NotifierProvider<PictureNotifier, PictureState>(
  PictureNotifier.new,
);
