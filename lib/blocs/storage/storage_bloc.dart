import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/repositories/storage_repository.dart';

part 'storage_events.dart';
part 'storage_states.dart';

class StorageBloc extends Bloc<StorageEvent, StorageState> {
  @override
  StorageState get initialState => StorageLoading();

  @override
  Stream<StorageState> mapEventToState(StorageEvent event) async* {
    if (event is StorageRoot) {
      yield StorageLoading();
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
      yield StorageLoading();
      Storage results = await storageRepository.storage(event.id);
      yield StorageStorageDetailResults(results);
    }
    if (event is StorageItemDetail) {
      yield StorageLoading();
      Item results = await storageRepository.item(event.id);
      yield StorageItemDetailResults(results);
    }
  }
}
