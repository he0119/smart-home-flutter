import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/repositories/storage_repository.dart';

part 'storage_events.dart';
part 'storage_states.dart';

class StorageBloc extends Bloc<StorageEvent, StorageState> {
  @override
  StorageState get initialState => StorageInitial();

  @override
  Stream<StorageState> mapEventToState(StorageEvent event) async* {
    if (event is StorageSearchChanged) {
      yield StorageLoading();
      try {
        List<dynamic> results = await storageRepository.search(event.key);
        if (results == null){
          yield StorageSearchResults([], []);
          return;
        }
        yield StorageSearchResults(results[0], results[1]);
      } on StorageException catch (e) {
        yield StorageError(e.message);
      } catch (e) {
        yield StorageError('错误：$e');
      }
    }
    if (event is StorageSearchStarted) {
      yield StorageSearchResults([], []);
    }
  }
}
