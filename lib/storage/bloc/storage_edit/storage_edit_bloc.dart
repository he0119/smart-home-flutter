import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smarthome/storage/model/storage.dart';
import 'package:smarthome/storage/repository/storage_repository.dart';
import 'package:smarthome/utils/exceptions.dart';

part 'storage_edit_event.dart';
part 'storage_edit_state.dart';

class StorageEditBloc extends Bloc<StorageEditEvent, StorageEditState> {
  final StorageRepository storageRepository;

  StorageEditBloc({
    required this.storageRepository,
  }) : super(StorageEditInitial());

  @override
  Stream<StorageEditState> mapEventToState(
    StorageEditEvent event,
  ) async* {
    if (event is StorageUpdated) {
      yield StorageEditInProgress();
      try {
        final storage = await storageRepository.updateStorage(
          id: event.id,
          name: event.name,
          parentId: event.parentId,
          description: event.description,
        );
        yield StorageUpdateSuccess(storage: storage);
      } on MyException catch (e) {
        yield StorageEditFailure(e.message);
      }
    }
    if (event is StorageAdded) {
      yield StorageEditInProgress();
      try {
        final storage = await storageRepository.addStorage(
          name: event.name,
          parentId: event.parentId,
          description: event.description,
        );
        yield StorageAddSuccess(storage: storage);
      } on MyException catch (e) {
        yield StorageEditFailure(e.message);
      }
    }
    if (event is StorageDeleted) {
      yield StorageEditInProgress();
      try {
        await storageRepository.deleteStorage(storageId: event.storage.id);
        yield StorageDeleteSuccess(storage: event.storage);
      } on MyException catch (e) {
        yield StorageEditFailure(e.message);
      }
    }
  }
}
