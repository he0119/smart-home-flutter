import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/repositories/storage_repository.dart';

part 'search_events.dart';
part 'search_states.dart';

class StorageSearchBloc extends Bloc<StorageSearchEvent, StorageSearchState> {
  @override
  StorageSearchState get initialState =>
      StorageSearchResults(items: [], storages: [], term: '');

  @override
  Stream<StorageSearchState> mapEventToState(StorageSearchEvent event) async* {
    if (event is StorageSearchChanged) {
      if (event.key.isEmpty) {
        yield StorageSearchResults(items: [], storages: [], term: '');
        return;
      }
      yield StorageSearchLoading();
      try {
        List<dynamic> results = await storageRepository.search(event.key);
        yield StorageSearchResults(
          items: results[0],
          storages: results[1],
          term: event.key,
        );
      } catch (e) {
        yield StorageSearchError(e.message);
      }
    }
  }
}
