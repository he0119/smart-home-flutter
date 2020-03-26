import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/repositories/graphql_api_client.dart';
import 'package:smart_home/repositories/storage_repository.dart';

part 'storage_home_event.dart';
part 'storage_home_state.dart';

enum ItemType { expired, nearExpired, recentlyAdded, recentlyUpdated, all }

class StorageHomeBloc extends Bloc<StorageHomeEvent, StorageHomeState> {
  @override
  StorageHomeState get initialState => StorageHomeInProgress();

  @override
  Stream<StorageHomeState> mapEventToState(
    StorageHomeEvent event,
  ) async* {
    if (event is StorageHomeStarted) {
      try {
        Map<String, List<Item>> homepage = await storageRepository.homePage();
        yield StorageHomeSuccess(
          recentlyAddedItems: homepage['recentlyAddedItems'],
          recentlyUpdatedItems: homepage['recentlyUpdatedItems'],
          expiredItems: homepage['expiredItems'],
          nearExpiredItems: homepage['nearExpiredItems'],
          itemType: ItemType.all,
        );
      } on GraphQLApiException catch (e) {
        yield StorageHomeError(message: e.message);
      }
    }
    if (event is StorageHomeChanged) {
      yield StorageHomeInProgress();
      try {
        switch (event.itemType) {
          case ItemType.expired:
            List<Item> expiredItems = await storageRepository.expiredItems();
            yield StorageHomeSuccess(
              expiredItems: expiredItems,
              itemType: ItemType.expired,
            );
            break;
          case ItemType.nearExpired:
            List<Item> nearExpiredItems = await storageRepository
                .nearExpiredItems(within: 365, number: 50);
            yield StorageHomeSuccess(
              nearExpiredItems: nearExpiredItems,
              itemType: ItemType.nearExpired,
            );
            break;
          case ItemType.recentlyAdded:
            List<Item> recentlyAddedItems =
                await storageRepository.recentlyAddedItems(number: 50);
            yield StorageHomeSuccess(
              recentlyAddedItems: recentlyAddedItems,
              itemType: ItemType.recentlyAdded,
            );
            break;
          case ItemType.recentlyUpdated:
            List<Item> recentlyUpdatedItems =
                await storageRepository.recentlyUpdatedItems(number: 50);
            yield StorageHomeSuccess(
              recentlyUpdatedItems: recentlyUpdatedItems,
              itemType: ItemType.recentlyUpdated,
            );
            break;
          case ItemType.all:
            Map<String, List<Item>> homepage =
                await storageRepository.homePage();
            yield StorageHomeSuccess(
              recentlyAddedItems: homepage['recentlyAddedItems'],
              recentlyUpdatedItems: homepage['recentlyUpdatedItems'],
              expiredItems: homepage['expiredItems'],
              nearExpiredItems: homepage['nearExpiredItems'],
              itemType: ItemType.all,
            );
            break;
        }
      } on GraphQLApiException catch (e) {
        yield StorageHomeError(message: e.message);
      }
    }

    if (event is StorageHomeRefreshed) {
      yield StorageHomeInProgress();
      try {
        switch (event.itemType) {
          case ItemType.expired:
            List<Item> expiredItems =
                await storageRepository.expiredItems(cache: false);
            yield StorageHomeSuccess(
              expiredItems: expiredItems,
              itemType: ItemType.expired,
            );
            break;
          case ItemType.nearExpired:
            List<Item> nearExpiredItems = await storageRepository
                .nearExpiredItems(within: 360, number: 50, cache: false);
            yield StorageHomeSuccess(
              nearExpiredItems: nearExpiredItems,
              itemType: ItemType.nearExpired,
            );
            break;
          case ItemType.recentlyAdded:
            List<Item> recentlyAddedItems =
                await storageRepository.recentlyAddedItems(
              number: 50,
              cache: false,
            );
            yield StorageHomeSuccess(
              recentlyAddedItems: recentlyAddedItems,
              itemType: ItemType.recentlyAdded,
            );
            break;
          case ItemType.recentlyUpdated:
            List<Item> recentlyUpdatedItems =
                await storageRepository.recentlyUpdatedItems(
              number: 50,
              cache: false,
            );
            yield StorageHomeSuccess(
              recentlyUpdatedItems: recentlyUpdatedItems,
              itemType: ItemType.recentlyUpdated,
            );
            break;
          case ItemType.all:
            Map<String, List<Item>> homepage =
                await storageRepository.homePage(cache: false);
            yield StorageHomeSuccess(
              recentlyAddedItems: homepage['recentlyAddedItems'],
              recentlyUpdatedItems: homepage['recentlyUpdatedItems'],
              expiredItems: homepage['expiredItems'],
              nearExpiredItems: homepage['nearExpiredItems'],
              itemType: ItemType.all,
            );
            break;
        }
      } on GraphQLApiException catch (e) {
        yield StorageHomeError(message: e.message);
      }
    }
  }
}
