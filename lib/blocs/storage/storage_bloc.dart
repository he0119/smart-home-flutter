import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/repositories/storage_repository.dart';

part 'storage_events.dart';
part 'storage_states.dart';

class StorageBloc extends Bloc<StorageEvent, StorageState> {
  @override
  StorageState get initialState => StorageInProgress();

  @override
  Stream<StorageState> mapEventToState(StorageEvent event) async* {
    // 根位置
    if (event is StorageStarted) {
      yield StorageInProgress();
      try {
        List<Storage> results = await storageRepository.rootStorage();
        yield StorageRootResults(results);
      } catch (e) {
        yield StorageStorageError(id: '0', message: e.message);
      }
    }

    if (event is StorageRefreshRoot) {
      yield StorageInProgress();
      try {
        List<Storage> results =
            await storageRepository.rootStorage(cache: false);
        yield StorageRootResults(results);
      } catch (e) {
        yield StorageStorageError(id: '0', message: e.message);
      }
    }

    // 位置相关
    if (event is StorageStorageDetail) {
      yield StorageInProgress();
      try {
        Storage results = await storageRepository.storage(event.id);
        yield StorageStorageDetailResults(results);
      } catch (e) {
        yield StorageStorageError(id: event.id, message: e.message);
      }
    }

    if (event is StorageRefreshStorageDetail) {
      yield StorageInProgress();
      try {
        Storage results =
            await storageRepository.storage(event.id, cache: false);
        yield StorageStorageDetailResults(results);
      } catch (e) {
        yield StorageStorageError(id: event.id, message: e.message);
      }
    }

    if (event is StorageUpdateStorage) {
      yield StorageInProgress();
      try {
        await storageRepository.updateStorage(
          id: event.id,
          name: event.name,
          parentId: event.parentId,
          description: event.description,
        );
        yield StorageUpdateStorageSuccess();
        // 刷新受到影响的存储的位置
        add(StorageRefreshStorageDetail(id: event.id));
        if (event.oldParentId != null) {
          add(StorageRefreshStorageDetail(id: event.oldParentId));
        } else {
          add(StorageRefreshRoot());
        }
        if (event.parentId != null) {
          add(StorageRefreshStorageDetail(id: event.parentId));
        } else {
          add(StorageRefreshRoot());
        }
      } catch (e) {
        yield StorageStorageError(message: e.message);
      }
    }

    if (event is StorageAddStorage) {
      try {
        await storageRepository.addStorage(
          name: event.name,
          parentId: event.parentId,
          description: event.description,
        );
        yield StorageAddStorageSuccess();
        // 刷新受到影响的存储的位置
        if (event.parentId != null) {
          add(StorageRefreshStorageDetail(id: event.parentId));
        } else {
          add(StorageRefreshRoot());
        }
        add(StorageRefreshStorages());
      } catch (e) {
        yield StorageStorageError(message: e.message);
      }
    }

    if (event is StorageDeleteStorage) {
      yield StorageInProgress();
      try {
        String id = await storageRepository.deleteStorage(id: event.storage.id);
        yield StorageStorageDeleted(id);
        // 刷新受到影响的数据
        if (event.storage.parent != null) {
          add(StorageRefreshStorageDetail(id: event.storage.parent.id));
        } else {
          add(StorageRefreshRoot());
        }
        add(StorageRefreshStorages());
      } catch (e) {
        // FIXME: 思考展示删除错误的好方法
        yield StorageStorageError(message: e.message);
      }
    }

    // 物品相关
    if (event is StorageItemDetail) {
      yield StorageInProgress();
      Item results = await storageRepository.item(event.id);
      yield StorageItemDetailResults(results);
    }

    if (event is StorageRefreshItemDetail) {
      yield StorageInProgress();
      Item results = await storageRepository.item(event.id, cache: false);
      yield StorageItemDetailResults(results);
    }

    if (event is StorageUpdateItem) {
      await storageRepository.updateItem(
        id: event.id,
        name: event.name,
        number: event.number,
        storageId: event.storageId,
        description: event.description,
        price: event.price,
        expirationDate: event.expirationDate,
      );
      yield StorageUpdateItemSuccess();
      // 刷新受到影响的存储的位置
      add(StorageRefreshItemDetail(id: event.id));
      add(StorageRefreshStorageDetail(id: event.storageId));
      add(StorageRefreshStorageDetail(id: event.oldStorageId));
    }

    if (event is StorageAddItem) {
      await storageRepository.addItem(
        name: event.name,
        number: event.number,
        storageId: event.storageId,
        description: event.description,
        price: event.price,
        expirationDate: event.expirationDate,
      );
      yield StorageAddItemSuccess();
      // 刷新受到影响的存储的位置
      add(StorageRefreshStorageDetail(id: event.storageId));
    }

    if (event is StorageDeleteItem) {
      yield StorageInProgress();
      String id = await storageRepository.deleteItem(id: event.item.id);
      yield StorageItemDeleted(id);
      // 刷新受到影响的数据
      add(StorageRefreshStorageDetail(id: event.item.storage.id));
    }

    // 刷新所有位置的数据
    if (event is StorageRefreshStorages) {
      yield StorageInProgress();
      await storageRepository.storages(cache: false);
    }
  }
}
