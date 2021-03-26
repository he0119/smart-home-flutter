import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smarthome/models/models.dart';
import 'package:smarthome/repositories/storage_repository.dart';
import 'package:smarthome/utils/exceptions.dart';

part 'picture_event.dart';
part 'picture_state.dart';

class PictureBloc extends Bloc<PictureEvent, PictureState> {
  final StorageRepository storageRepository;

  PictureBloc({
    required this.storageRepository,
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
      } on MyException catch (e) {
        yield PictureFailure(
          e.message,
          id: event.id,
        );
      }
    }
    final PictureState currentState = state;
    if (event is PictureRefreshed && currentState is PictureSuccess) {
      yield PictureInProgress();
      try {
        final picture = await storageRepository.picture(
          id: currentState.picture.id,
          cache: false,
        );
        if (picture != null) {
          yield PictureSuccess(picture: picture);
        }
      } on MyException catch (e) {
        yield PictureFailure(
          e.message,
          id: currentState.picture.id,
        );
      }
    }
  }
}
