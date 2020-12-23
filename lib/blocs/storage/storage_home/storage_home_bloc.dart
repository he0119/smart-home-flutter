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
    if (event is StorageHomeChanged) {
      final currentState = state;
      if (currentState is StorageHomeSuccess &&
          currentState.itemType != event.itemType) {
        yield StorageHomeInProgress();
      }
      try {
        switch (event.itemType) {
          case ItemType.expired:
            List<Item> expiredItems =
                await storageRepository.expiredItems(cache: !event.refresh);
            yield StorageHomeSuccess(
              expiredItems: expiredItems,
              itemType: ItemType.expired,
            );
            break;
          case ItemType.nearExpired:
            List<Item> nearExpiredItems =
                await storageRepository.nearExpiredItems(cache: !event.refresh);
            yield StorageHomeSuccess(
              nearExpiredItems: nearExpiredItems,
              itemType: ItemType.nearExpired,
            );
            break;
          case ItemType.recentlyCreated:
            List<Item> recentlyCreatedItems = await storageRepository
                .recentlyCreatedItems(cache: !event.refresh);
            yield StorageHomeSuccess(
              recentlyCreatedItems: recentlyCreatedItems,
              itemType: ItemType.recentlyCreated,
            );
            break;
          case ItemType.recentlyEdited:
            List<Item> recentlyEditedItems = await storageRepository
                .recentlyEditedItems(cache: !event.refresh);
            yield StorageHomeSuccess(
              recentlyEditedItems: recentlyEditedItems,
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
          e.message,
          itemType: event.itemType,
        );
      }
    }
  }
}
