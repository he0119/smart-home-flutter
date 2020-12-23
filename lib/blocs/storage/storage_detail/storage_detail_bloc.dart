import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/repositories/storage_repository.dart';

part 'storage_detail_event.dart';
part 'storage_detail_state.dart';

class StorageDetailBloc extends Bloc<StorageDetailEvent, StorageDetailState> {
  final StorageRepository storageRepository;
  bool backImmediately;

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
            id: currentState.storage.id,
            itemCursor: currentState.itemEndCursor,
            storageCursor: currentState.stroageEndCursor);
        yield currentState.copyWith(
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
    if (event is StorageDetailRoot) {
      backImmediately = false;
      yield StorageDetailInProgress();
      try {
        List<Storage> results = await storageRepository.rootStorage();
        yield StorageDetailRootSuccess(storages: results);
      } catch (e) {
        yield StorageDetailFailure(
          e.message,
          storageId: null,
        );
      }
    }
    if (event is StorageDetailRootRefreshed) {
      backImmediately = false;
      try {
        List<Storage> results =
            await storageRepository.rootStorage(cache: false);
        yield StorageDetailRootSuccess(storages: results);
      } catch (e) {
        yield StorageDetailFailure(
          e.message,
          storageId: null,
        );
      }
    }
    if (event is StorageDetailChanged) {
      // 是否马上返回上级界面
      if (backImmediately == null) {
        backImmediately = true;
      } else {
        backImmediately = false;
      }
      yield StorageDetailInProgress();
      try {
        final results = await storageRepository.storage(id: event.id);
        yield StorageDetailSuccess(
          backImmediately: backImmediately,
          storage: results.item1,
          hasNextPage: results.item3 || results.item5,
          stroageEndCursor: results.item2,
          itemEndCursor: results.item4,
        );
      } catch (e) {
        yield StorageDetailFailure(
          e.message,
          storageId: event.id,
        );
      }
    }
    if (event is StorageDetailRefreshed) {
      try {
        final results = await storageRepository.storage(
          id: event.id,
          cache: false,
        );
        yield StorageDetailSuccess(
          backImmediately: backImmediately,
          storage: results.item1,
          hasNextPage: results.item3 || results.item5,
          stroageEndCursor: results.item2,
          itemEndCursor: results.item4,
        );
      } catch (e) {
        yield StorageDetailFailure(
          e.message,
          storageId: event.id,
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
