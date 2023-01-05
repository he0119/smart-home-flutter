import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:smarthome/storage/model/storage.dart';
import 'package:smarthome/storage/repository/storage_repository.dart';
import 'package:smarthome/utils/exceptions.dart';

part 'search_events.dart';
part 'search_states.dart';

class StorageSearchBloc extends Bloc<StorageSearchEvent, StorageSearchState> {
  final StorageRepository storageRepository;

  StorageSearchBloc({
    required this.storageRepository,
  }) : super(StorageSearchInitial()) {
    on<StorageSearchChanged>(_onStorageSearchChanged,
        transformer: debounce(const Duration(milliseconds: 300)));
  }

  FutureOr<void> _onStorageSearchChanged(
      StorageSearchChanged event, Emitter<StorageSearchState> emit) async {
    if (event.key.isEmpty) {
      emit(StorageSearchInitial());
      return;
    }
    emit(StorageSearchInProgress());
    try {
      final results = await storageRepository.search(
        event.key,
        isDeleted: event.isDeleted,
        missingStorage: event.missingStorage,
      );
      emit(StorageSearchSuccess(
        items: results.item1,
        storages: results.item2,
        term: event.key,
      ));
    } on MyException catch (e) {
      emit(StorageSearchFailure(e.message));
    }
  }

  EventTransformer<StorageSearchEvent> debounce<StorageSearchEvent>(
      Duration duration) {
    return (events, mapper) => events.debounceTime(duration).switchMap(mapper);
  }
}
