import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/repositories/storage_repository.dart';

part 'picture_event.dart';
part 'picture_state.dart';

class PictureBloc extends Bloc<PictureEvent, PictureState> {
  final StorageRepository storageRepository;

  PictureBloc({
    @required this.storageRepository,
  }) : super(PictureInProgress());

  @override
  Stream<PictureState> mapEventToState(
    PictureEvent event,
  ) async* {
    if (event is PictureStarted) {
      try {
        final picture = await storageRepository.picture(
          id: event.id,
        );
        if (picture == null) {
          yield PictureFailure(
            '获取图片失败，图片不存在',
            id: event.id,
          );
          return;
        }
        yield PictureSuccess(picture: picture);
      } catch (e) {
        yield PictureFailure(
          e.message,
          id: event.id,
        );
      }
    }
    final currentState = state;
    if (event is PictureRefreshed && currentState is PictureSuccess) {
      yield PictureInProgress();
      try {
        Picture picture = await storageRepository.picture(
          id: currentState.picture.id,
          cache: false,
        );
        yield PictureSuccess(picture: picture);
      } catch (e) {
        yield PictureFailure(
          e.message,
          id: currentState.picture.id,
        );
      }
    }
  }
}
