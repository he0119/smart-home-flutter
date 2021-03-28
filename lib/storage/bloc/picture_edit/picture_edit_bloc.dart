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
  }) : super(PictureEditInitial());

  @override
  Stream<PictureEditState> mapEventToState(
    PictureEditEvent event,
  ) async* {
    if (event is PictureUpdated) {
      yield PictureEditInProgress();
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
        yield PictureUpdateSuccess(picture: picture);
      } on MyException catch (e) {
        yield PictureEditFailure(e.message);
      }
    }
    if (event is PictureAdded) {
      yield PictureEditInProgress();
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
        yield PictureAddSuccess(picture: picture);
      } on MyException catch (e) {
        yield PictureEditFailure(e.message);
      }
    }
    if (event is PictureDeleted) {
      yield PictureEditInProgress();
      try {
        await storageRepository.deletePicture(pictureId: event.picture.id);
        yield PictureDeleteSuccess(picture: event.picture);
      } on MyException catch (e) {
        yield PictureEditFailure(e.message);
      }
    }
  }
}
