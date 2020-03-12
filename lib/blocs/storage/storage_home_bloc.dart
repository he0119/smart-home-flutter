import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/repositories/storage_repository.dart';

part 'storage_home_event.dart';
part 'storage_home_state.dart';

class StorageHomeBloc extends Bloc<StorageHomeEvent, StorageHomeState> {
  @override
  StorageHomeState get initialState => StorageHomeInitial();

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
        );
      } catch (e) {
        yield StorageHomeError(message: e.message);
      }
    }
    if (event is StorageHomeRefreshed) {
      try {
        Map<String, List<Item>> homepage =
            await storageRepository.homePage(cache: false);
        yield StorageHomeSuccess(
          recentlyAddedItems: homepage['recentlyAddedItems'],
          recentlyUpdatedItems: homepage['recentlyUpdatedItems'],
          expiredItems: homepage['expiredItems'],
          nearExpiredItems: homepage['nearExpiredItems'],
        );
      } catch (e) {
        yield StorageHomeError(message: e.message);
      }
    }
  }
}
