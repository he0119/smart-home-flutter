import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/repositories/storage_repository.dart';

part 'search_events.dart';
part 'search_states.dart';

class StorageSearchBloc extends Bloc<StorageSearchEvent, StorageSearchState> {
  @override
  StorageSearchState get initialState => StorageSearchResults([], []);

  @override
  Stream<StorageSearchState> mapEventToState(StorageSearchEvent event) async* {
    if (event is StorageSearchChanged) {
      if (event.key.isEmpty) {
        yield StorageSearchResults([], []);
        return;
      }
      yield StorageSearchLoading();
      try {
        List<dynamic> results = await storageRepository.search(event.key);
        yield StorageSearchResults(results[0], results[1]);
      } on StorageException catch (e) {
        yield StorageSearchError(e.message);
      } catch (e) {
        yield StorageSearchError('错误：$e');
      }
    }
  }
}
