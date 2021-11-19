import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smarthome/storage/model/storage.dart';
import 'package:smarthome/storage/repository/storage_repository.dart';
import 'package:smarthome/utils/exceptions.dart';

part 'picture_event.dart';
part 'picture_state.dart';

class PictureBloc extends Bloc<PictureEvent, PictureState> {
  final StorageRepository storageRepository;

  PictureBloc({
    required this.storageRepository,
  }) : super(PictureInProgress()) {
    on<PictureStarted>(_onPictureStarted);
    on<PictureRefreshed>(_onPictureRefreshed);
  }

  FutureOr<void> _onPictureStarted(
      PictureStarted event, Emitter<PictureState> emit) async {
    try {
      final picture = await storageRepository.picture(
        id: event.id,
      );
      if (picture == null) {
        emit(PictureFailure(
          '获取图片失败，图片不存在',
          id: event.id,
        ));
        return;
      }
      emit(PictureSuccess(picture: picture));
    } on MyException catch (e) {
      emit(PictureFailure(
        e.message,
        id: event.id,
      ));
    }
  }

  FutureOr<void> _onPictureRefreshed(
      PictureRefreshed event, Emitter<PictureState> emit) async {
    final currentState = state;
    if (currentState is PictureSuccess) {
      emit(PictureInProgress());
      try {
        final picture = await storageRepository.picture(
          id: currentState.picture.id,
          cache: false,
        );
        if (picture != null) {
          emit(PictureSuccess(picture: picture));
        }
      } on MyException catch (e) {
        emit(PictureFailure(
          e.message,
          id: currentState.picture.id,
        ));
      }
    }
  }
}
