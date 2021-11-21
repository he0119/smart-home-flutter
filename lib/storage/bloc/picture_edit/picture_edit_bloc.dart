import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smarthome/storage/model/storage.dart';
import 'package:smarthome/storage/repository/storage_repository.dart';
import 'package:smarthome/utils/exceptions.dart';

part 'picture_edit_event.dart';
part 'picture_edit_state.dart';

class PictureEditBloc extends Bloc<PictureEditEvent, PictureEditState> {
  final StorageRepository storageRepository;

  PictureEditBloc({
    required this.storageRepository,
  }) : super(PictureEditInitial()) {
    on<PictureUpdated>(_onPictureUpdated);
    on<PictureAdded>(_onPictureAdded);
    on<PictureDeleted>(_onPictureDeleted);
  }

  FutureOr<void> _onPictureUpdated(
      PictureUpdated event, Emitter<PictureEditState> emit) async {
    emit(PictureEditInProgress());
    try {
      final picture = await storageRepository.updatePicture(
        id: event.id,
        picturePath: event.picturePath,
        description: event.description,
        boxX: event.boxX,
        boxY: event.boxY,
        boxH: event.boxH,
        boxW: event.boxW,
      );
      emit(PictureUpdateSuccess(picture: picture));
    } on MyException catch (e) {
      emit(PictureEditFailure(e.message));
    }
  }

  FutureOr<void> _onPictureAdded(
      PictureAdded event, Emitter<PictureEditState> emit) async {
    emit(PictureEditInProgress());
    try {
      final picture = await storageRepository.addPicture(
        itemId: event.itemId,
        picturePath: event.picturePath,
        description: event.description,
        boxX: event.boxX,
        boxY: event.boxY,
        boxH: event.boxH,
        boxW: event.boxW,
      );
      emit(PictureAddSuccess(picture: picture));
    } on MyException catch (e) {
      emit(PictureEditFailure(e.message));
    }
  }

  FutureOr<void> _onPictureDeleted(
      PictureDeleted event, Emitter<PictureEditState> emit) async {
    emit(PictureEditInProgress());
    try {
      await storageRepository.deletePicture(pictureId: event.picture.id);
      emit(PictureDeleteSuccess(picture: event.picture));
    } on MyException catch (e) {
      emit(PictureEditFailure(e.message));
    }
  }
}
