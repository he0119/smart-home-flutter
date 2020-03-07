import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/repositories/storage_repository.dart';

part 'storage_events.dart';
part 'storage_states.dart';

class StorageBloc extends Bloc<StorageEvent, StorageState> {
  @override
  StorageState get initialState => StorageInProgress();

  @override
  Stream<StorageState> mapEventToState(StorageEvent event) async* {
    if (event is StorageStarted) {
      yield StorageInProgress();
      try {
        List<Storage> results = await storageRepository.rootStorage();
        yield StorageRootResults(results);
      } on StorageException catch (e) {
        yield StorageError(e.message);
      } catch (e) {
        yield StorageError('错误：$e');
      }
    }

    if (event is StorageStorageDetail) {
      yield StorageInProgress();
      Storage results = await storageRepository.storage(event.id);
      yield StorageStorageDetailResults(results);
    }

    if (event is StorageItemDetail) {
      yield StorageInProgress();
      Item results = await storageRepository.item(event.id);
      yield StorageItemDetailResults(results);
    }

    if (event is StorageDeleteItem) {
      yield StorageInProgress();
      String id = await storageRepository.deleteItem(id: event.id);
      yield StorageItemDeleted(id);
    }

    if (event is StorageDeleteStorage) {
      yield StorageInProgress();
      String id = await storageRepository.deleteStorage(id: event.id);
      yield StorageStorageDeleted(id);
    }

    if (event is StorageRefreshStorageDetail) {
      yield StorageInProgress();
      Storage results = await storageRepository.storage(event.id, cache: false);
      yield StorageStorageDetailResults(results);
    }

    if (event is StorageRefreshItemDetail) {
      yield StorageInProgress();
      Item results = await storageRepository.item(event.id, cache: false);
      yield StorageItemDetailResults(results);
    }
    if (event is StorageRefreshRoot) {
      yield StorageInProgress();
      List<Storage> results = await storageRepository.rootStorage(cache: false);
      yield StorageRootResults(results);
    }
  }
}
