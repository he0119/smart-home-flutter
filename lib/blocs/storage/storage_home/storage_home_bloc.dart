import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:smart_home/models/models.dart';
import 'package:smart_home/repositories/storage_repository.dart';

part 'storage_home_event.dart';
part 'storage_home_state.dart';

enum ItemType { expired, nearExpired, recentlyCreated, recentlyEdited, all }

class StorageHomeBloc extends Bloc<StorageHomeEvent, StorageHomeState> {
  final StorageRepository storageRepository;

  StorageHomeBloc({@required this.storageRepository})
      : super(StorageHomeInProgress());

  @override
  Stream<StorageHomeState> mapEventToState(
    StorageHomeEvent event,
  ) async* {
    final currentState = state;
    if (event is StorageHomeFetched && _hasReachedMax(currentState)) {
      // 如果切换了物品种类，则显示加载提示
      if (currentState is StorageHomeSuccess &&
          currentState.itemType != event.itemType) {
        yield StorageHomeInProgress();
      }
      try {
        if (currentState is StorageHomeSuccess &&
            currentState.itemType == event.itemType &&
            !event.refresh) {
          switch (event.itemType) {
            case ItemType.expired:
              final results = await storageRepository.expiredItems(
                after: currentState.pageInfo.endCursor,
              );
              yield StorageHomeSuccess(
                expiredItems: results.item1,
                pageInfo: results.item2,
                itemType: ItemType.expired,
              );
              break;
            case ItemType.nearExpired:
              final results = await storageRepository.nearExpiredItems(
                after: currentState.pageInfo.endCursor,
              );
              yield StorageHomeSuccess(
                nearExpiredItems: results.item1,
                pageInfo: results.item2,
                itemType: ItemType.nearExpired,
              );
              break;
            case ItemType.recentlyCreated:
              final results = await storageRepository.recentlyCreatedItems(
                after: currentState.pageInfo.endCursor,
              );
              yield StorageHomeSuccess(
                recentlyCreatedItems: results.item1,
                pageInfo: results.item2,
                itemType: ItemType.recentlyCreated,
              );
              break;
            case ItemType.recentlyEdited:
              final results = await storageRepository.recentlyEditedItems(
                after: currentState.pageInfo.endCursor,
              );
              yield StorageHomeSuccess(
                recentlyEditedItems: results.item1,
                pageInfo: results.item2,
                itemType: ItemType.recentlyEdited,
              );
              break;
            case ItemType.all:
              break;
          }
          return;
        }
        switch (event.itemType) {
          case ItemType.expired:
            final results =
                await storageRepository.expiredItems(cache: !event.refresh);
            yield StorageHomeSuccess(
              expiredItems: results.item1,
              pageInfo: results.item2,
              itemType: ItemType.expired,
            );
            break;
          case ItemType.nearExpired:
            final results =
                await storageRepository.nearExpiredItems(cache: !event.refresh);
            yield StorageHomeSuccess(
              nearExpiredItems: results.item1,
              pageInfo: results.item2,
              itemType: ItemType.nearExpired,
            );
            break;
          case ItemType.recentlyCreated:
            final results = await storageRepository.recentlyCreatedItems(
                cache: !event.refresh);
            yield StorageHomeSuccess(
              recentlyCreatedItems: results.item1,
              pageInfo: results.item2,
              itemType: ItemType.recentlyCreated,
            );
            break;
          case ItemType.recentlyEdited:
            final results = await storageRepository.recentlyEditedItems(
                cache: !event.refresh);
            yield StorageHomeSuccess(
              recentlyEditedItems: results.item1,
              pageInfo: results.item2,
              itemType: ItemType.recentlyEdited,
            );
            break;
          case ItemType.all:
            Map<String, List<Item>> homepage =
                await storageRepository.homePage(cache: !event.refresh);
            yield StorageHomeSuccess(
              recentlyCreatedItems: homepage['recentlyCreatedItems'],
              recentlyEditedItems: homepage['recentlyEditedItems'],
              expiredItems: homepage['expiredItems'],
              nearExpiredItems: homepage['nearExpiredItems'],
              itemType: ItemType.all,
            );
            break;
        }
      } catch (e) {
        yield StorageHomeFailure(
          e?.message ?? e.toString(),
          itemType: event.itemType,
        );
      }
    }
  }
}

bool _hasReachedMax(StorageHomeState currentState) {
  if (currentState is StorageHomeSuccess) {
    return !currentState.pageInfo.hasNextPage;
  }
  return false;
}
