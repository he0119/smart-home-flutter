import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smarthome/storage/model/storage.dart';
import 'package:smarthome/storage/repository/storage_repository.dart';
import 'package:smarthome/utils/exceptions.dart';
part 'search_events.dart';
part 'search_states.dart';

class StorageSearchBloc extends Bloc<StorageSearchEvent, StorageSearchState> {
  final StorageRepository storageRepository;

  StorageSearchBloc({
    required this.storageRepository,
  }) : super(StorageSearchInitial());

  @override
  Stream<Transition<StorageSearchEvent, StorageSearchState>> transformEvents(
      events, transitionFn) {
    return events
        .debounceTime(const Duration(milliseconds: 300))
        .switchMap(transitionFn);
  }

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
      } on MyException catch (e) {
        yield StorageSearchFailure(e.message);
      }
    }
  }
}
