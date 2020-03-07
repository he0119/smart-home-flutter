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

    if (event is StorageAddItem) {
      yield StorageInProgress();
      Item results = await storageRepository.addItem(event.item);
      yield StorageAddItemSuccess(results);
    }

    if (event is StorageAddStorage) {
      yield StorageInProgress();
      Storage results = await storageRepository.addStorage(event.storage);
      yield StorageAddStorageSuccess(results);
    }

    if (event is StorageUpdateStorage) {
      yield StorageInProgress();
      Storage results = await storageRepository.updateStorage(event.storage);
      yield StorageUpdateStorageSuccess(results);
    }
  }
}
