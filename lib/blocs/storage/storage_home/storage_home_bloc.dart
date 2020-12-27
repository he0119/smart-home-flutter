import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:smart_home/models/models.dart';
import 'package:smart_home/repositories/storage_repository.dart';

part 'storage_home_event.dart';
part 'storage_home_state.dart';

class StorageHomeBloc extends Bloc<StorageHomeEvent, StorageHomeState> {
  final StorageRepository storageRepository;

  StorageHomeBloc({@required this.storageRepository})
      : super(StorageHomeInProgress());

  @override
  Stream<StorageHomeState> mapEventToState(
    StorageHomeEvent event,
  ) async* {
    final currentState = state;
    if (event is StorageHomeFetched) {
      // 如果切换了物品种类，则显示加载提示
      if (currentState is StorageHomeSuccess &&
          currentState.itemType != event.itemType) {
        yield StorageHomeInProgress();
      }
      try {
        // 获取下一页
        if (currentState is StorageHomeSuccess &&
            !_hasReachedMax(currentState, event.itemType) &&
            event.cache) {
          switch (event.itemType) {
            case ItemType.expired:
              final results = await storageRepository.expiredItems(
                after: currentState.pageInfo.endCursor,
              );
              yield StorageHomeSuccess(
                expiredItems: currentState.expiredItems + results.item1,
                pageInfo: results.item2.copyWith(currentState.pageInfo),
                itemType: ItemType.expired,
              );
              break;
            case ItemType.nearExpired:
              final results = await storageRepository.nearExpiredItems(
                after: currentState.pageInfo.endCursor,
              );
              yield StorageHomeSuccess(
                nearExpiredItems: currentState.nearExpiredItems + results.item1,
                pageInfo: results.item2.copyWith(currentState.pageInfo),
                itemType: ItemType.nearExpired,
              );
              break;
            case ItemType.recentlyCreated:
              final results = await storageRepository.recentlyCreatedItems(
                after: currentState.pageInfo.endCursor,
              );
              yield StorageHomeSuccess(
                recentlyCreatedItems:
                    currentState.recentlyCreatedItems + results.item1,
                pageInfo: results.item2.copyWith(currentState.pageInfo),
                itemType: ItemType.recentlyCreated,
              );
              break;
            case ItemType.recentlyEdited:
              final results = await storageRepository.recentlyEditedItems(
                after: currentState.pageInfo.endCursor,
              );
              yield StorageHomeSuccess(
                recentlyEditedItems:
                    currentState.recentlyEditedItems + results.item1,
                pageInfo: results.item2.copyWith(currentState.pageInfo),
                itemType: ItemType.recentlyEdited,
              );
              break;
            case ItemType.all:
              break;
          }
        } else {
          switch (event.itemType) {
            case ItemType.expired:
              final results =
                  await storageRepository.expiredItems(cache: event.cache);
              yield StorageHomeSuccess(
                expiredItems: results.item1,
                pageInfo: results.item2,
                itemType: ItemType.expired,
              );
              break;
            case ItemType.nearExpired:
              final results =
                  await storageRepository.nearExpiredItems(cache: event.cache);
              yield StorageHomeSuccess(
                nearExpiredItems: results.item1,
                pageInfo: results.item2,
                itemType: ItemType.nearExpired,
              );
              break;
            case ItemType.recentlyCreated:
              final results = await storageRepository.recentlyCreatedItems(
                  cache: event.cache);
              yield StorageHomeSuccess(
                recentlyCreatedItems: results.item1,
                pageInfo: results.item2,
                itemType: ItemType.recentlyCreated,
              );
              break;
            case ItemType.recentlyEdited:
              final results = await storageRepository.recentlyEditedItems(
                  cache: event.cache);
              yield StorageHomeSuccess(
                recentlyEditedItems: results.item1,
                pageInfo: results.item2,
                itemType: ItemType.recentlyEdited,
              );
              break;
            case ItemType.all:
              Map<String, List<Item>> homepage =
                  await storageRepository.homePage(cache: event.cache);
              yield StorageHomeSuccess(
                  recentlyCreatedItems: homepage['recentlyCreatedItems'],
                  recentlyEditedItems: homepage['recentlyEditedItems'],
                  expiredItems: homepage['expiredItems'],
                  nearExpiredItems: homepage['nearExpiredItems'],
                  itemType: ItemType.all,
                  pageInfo: PageInfo(hasNextPage: false));
              break;
          }
        }
      } catch (e) {
        yield StorageHomeFailure(
          e.message,
          itemType: event.itemType,
        );
      }
    }
  }
}

bool _hasReachedMax(StorageHomeState currentState, ItemType currentType) {
  if (currentState is StorageHomeSuccess &&
      currentType == currentState.itemType) {
    return !currentState.pageInfo.hasNextPage;
  }
  return false;
}
