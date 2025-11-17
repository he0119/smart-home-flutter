import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/storage/model/storage.dart';
import 'package:smarthome/utils/exceptions.dart';

/// Picture edit state
class PictureEditState {
  final PictureEditStatus status;
  final String errorMessage;
  final Picture? picture;

  const PictureEditState({
    this.status = PictureEditStatus.initial,
    this.errorMessage = '',
    this.picture,
  });

  PictureEditState copyWith({
    PictureEditStatus? status,
    String? errorMessage,
    Picture? picture,
  }) {
    return PictureEditState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      picture: picture ?? this.picture,
    );
  }

  @override
  String toString() {
    return 'PictureEditState(status: $status, picture: ${picture?.id})';
  }
}

enum PictureEditStatus {
  initial,
  loading,
  addSuccess,
  updateSuccess,
  deleteSuccess,
  failure,
}

/// Picture edit notifier
class PictureEditNotifier extends Notifier<PictureEditState> {
  @override
  PictureEditState build() {
    return const PictureEditState();
  }

  Future<void> addPicture({
    required String itemId,
    required String picturePath,
    String? description,
    required double boxX,
    required double boxY,
    required double boxH,
    required double boxW,
  }) async {
    state = state.copyWith(status: PictureEditStatus.loading);

    try {
      final storageRepository = ref.read(storageRepositoryProvider);
      final picture = await storageRepository.addPicture(
        itemId: itemId,
        picturePath: picturePath,
        description: description,
        boxX: boxX,
        boxY: boxY,
        boxH: boxH,
        boxW: boxW,
      );
      state = state.copyWith(
        status: PictureEditStatus.addSuccess,
        picture: picture,
      );
    } on MyException catch (e) {
      state = state.copyWith(
        status: PictureEditStatus.failure,
        errorMessage: e.message,
      );
    }
  }

  Future<void> updatePicture({
    required String id,
    required String picturePath,
    String? description,
    double? boxX,
    double? boxY,
    double? boxH,
    double? boxW,
  }) async {
    state = state.copyWith(status: PictureEditStatus.loading);

    try {
      final storageRepository = ref.read(storageRepositoryProvider);
      final picture = await storageRepository.updatePicture(
        id: id,
        picturePath: picturePath,
        description: description,
        boxX: boxX,
        boxY: boxY,
        boxH: boxH,
        boxW: boxW,
      );
      state = state.copyWith(
        status: PictureEditStatus.updateSuccess,
        picture: picture,
      );
    } on MyException catch (e) {
      state = state.copyWith(
        status: PictureEditStatus.failure,
        errorMessage: e.message,
      );
    }
  }

  Future<void> deletePicture(Picture picture) async {
    state = state.copyWith(status: PictureEditStatus.loading);

    try {
      final storageRepository = ref.read(storageRepositoryProvider);
      await storageRepository.deletePicture(pictureId: picture.id);
      state = state.copyWith(
        status: PictureEditStatus.deleteSuccess,
        picture: picture,
      );
    } on MyException catch (e) {
      state = state.copyWith(
        status: PictureEditStatus.failure,
        errorMessage: e.message,
      );
    }
  }

  void reset() {
    state = const PictureEditState();
  }
}

/// Picture edit provider
final pictureEditProvider =
    NotifierProvider<PictureEditNotifier, PictureEditState>(
      PictureEditNotifier.new,
    );
