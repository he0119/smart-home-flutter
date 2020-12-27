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
  }) : super(StorageDetailInitial());

  @override
  Stream<StorageDetailState> mapEventToState(
    StorageDetailEvent event,
  ) async* {
    final currentState = state;
    if (event is StorageDetailFetched && !_hasReachedMax(currentState)) {
      try {
        // 获取下一页数据
        if (currentState is StorageDetailSuccess && !event.refresh) {
          if (currentState.storage == null) {
            final results = await storageRepository.rootStorage(
              after: currentState.storagePageInfo.endCursor,
            );
            yield currentState.copyWith(
              storages: currentState.storages + results.item1,
              storagePageInfo: results.item2,
            );
          } else {
            final results = await storageRepository.storage(
              name: currentState.storage.name,
              id: currentState.storage.id,
              itemCursor: currentState.itemPageInfo.endCursor,
              storageCursor: currentState.storagePageInfo.endCursor,
            );
            yield currentState.copyWith(
              storage: currentState.storage.copyWith(
                children:
                    currentState.storage.children + results.item1.children,
                items: currentState.storage.items + results.item1.items,
              ),
              storagePageInfo: results.item2,
              itemPageInfo: results.item3,
            );
          }
          return;
        }
        // 获取第一页数据
        if (event.name == '') {
          final results =
              await storageRepository.rootStorage(cache: !event.refresh);
          yield StorageDetailSuccess(
            storages: results.item1,
            storagePageInfo: results.item2,
          );
        } else {
          final results = await storageRepository.storage(
            name: event.name,
            id: event.id,
            cache: !event.refresh,
          );
          if (results == null) {
            yield StorageDetailFailure(
              '获取位置失败，位置不存在',
              name: event.name,
              id: event.id,
            );
          }
          yield StorageDetailSuccess(
            storage: results.item1,
            storagePageInfo: results.item2,
            itemPageInfo: results.item3,
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
  }
}

bool _hasReachedMax(StorageDetailState currentState) {
  if (currentState is StorageDetailSuccess) {
    return currentState.hasReachedMax;
  }
  return false;
}
