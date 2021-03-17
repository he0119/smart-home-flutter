import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smarthome/models/models.dart';
import 'package:smarthome/repositories/storage_repository.dart';

part 'search_events.dart';
part 'search_states.dart';

class StorageSearchBloc extends Bloc<StorageSearchEvent, StorageSearchState> {
  final StorageRepository storageRepository;

  StorageSearchBloc({
    required this.storageRepository,
  }) : super(StorageSearchInitial());

  @override
  Stream<StorageSearchState> mapEventToState(StorageSearchEvent event) async* {
    if (event is StorageSearchChanged) {
      if (event.key.isEmpty) {
        yield StorageSearchInitial();
        return;
      }
      yield StorageSearchInProgress();
      try {
        final results = await storageRepository.search(event.key);
        yield StorageSearchSuccess(
          items: results.item1,
          storages: results.item2,
          term: event.key,
        );
      } catch (e) {
        yield StorageSearchFailure(e.toString());
      }
    }
  }
}
