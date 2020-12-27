import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/repositories/storage_repository.dart';

part 'storage_detail_event.dart';
part 'storage_detail_state.dart';

class StorageDetailBloc extends Bloc<StorageDetailEvent, StorageDetailState> {
  final StorageRepository storageRepository;

  StorageDetailBloc({
    @required this.storageRepository,
  }) : super(StorageDetailInProgress());

  @override
  Stream<StorageDetailState> mapEventToState(
    StorageDetailEvent event,
  ) async* {
    final currentState = state;
    if (event is StorageDetailFetched && _hasNextPage(currentState)) {
      if (currentState is StorageDetailSuccess) {
        final results = await storageRepository.storage(
            name: currentState.storage.name,
            id: currentState.storage.id,
            itemCursor: currentState.itemEndCursor,
            storageCursor: currentState.stroageEndCursor);
        yield StorageDetailSuccess(
          storage: currentState.storage.copyWith(
            children: currentState.storage.children + results.item1.children,
            items: currentState.storage.items + results.item1.items,
          ),
          hasNextPage: results.item3 || results.item5,
          stroageEndCursor: results.item2,
          itemEndCursor: results.item4,
        );
      }
    }
    if (event is StorageDetailStarted) {
      try {
        if (event.name == '') {
          final storages = await storageRepository.rootStorage();
          yield StorageDetailSuccess(storages: storages);
        } else {
          final results =
              await storageRepository.storage(name: event.name, id: event.id);
          yield StorageDetailSuccess(
            storage: results.item1,
            hasNextPage: results.item3 || results.item5,
            stroageEndCursor: results.item2,
            itemEndCursor: results.item4,
          );
        }
      } catch (e) {
        yield StorageDetailFailure(
          e?.message ?? e.toString(),
          name: event.name,
          id: event.id,
        );
      }
    }
    if (event is StorageDetailRefreshed &&
        currentState is StorageDetailSuccess) {
      try {
        if (currentState.storage == null) {
          final storages = await storageRepository.rootStorage(cache: false);
          yield StorageDetailSuccess(storages: storages);
        } else {
          final results = await storageRepository.storage(
            name: currentState.storage.name,
            id: currentState.storage.id,
            cache: false,
          );
          yield StorageDetailSuccess(
            storage: results.item1,
            hasNextPage: results.item3 || results.item5,
            stroageEndCursor: results.item2,
            itemEndCursor: results.item4,
          );
        }
      } catch (e) {
        yield StorageDetailFailure(
          e?.message ?? e.toString(),
          name: currentState.storage.name,
          id: currentState.storage.id,
        );
      }
    }
  }
}

bool _hasNextPage(StorageDetailState currentState) {
  if (currentState is StorageDetailSuccess) {
    return currentState.hasNextPage;
  }
  return false;
}
