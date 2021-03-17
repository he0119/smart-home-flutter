import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smarthome/models/models.dart';
import 'package:smarthome/repositories/repositories.dart';

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
        Storage storage = await storageRepository.updateStorage(
          id: event.id,
          name: event.name,
          parentId: event.parentId,
          description: event.description,
        );
        yield StorageUpdateSuccess(storage: storage);
      } catch (e) {
        yield StorageEditFailure(e.toString());
      }
    }
    if (event is StorageAdded) {
      yield StorageEditInProgress();
      try {
        Storage storage = await storageRepository.addStorage(
          name: event.name,
          parentId: event.parentId,
          description: event.description,
        );
        yield StorageAddSuccess(storage: storage);
      } catch (e) {
        yield StorageEditFailure(e.toString());
      }
    }
    if (event is StorageDeleted) {
      yield StorageEditInProgress();
      try {
        await storageRepository.deleteStorage(storageId: event.storage.id);
        yield StorageDeleteSuccess(storage: event.storage);
      } catch (e) {
        yield StorageEditFailure(e.toString());
      }
    }
  }
}
