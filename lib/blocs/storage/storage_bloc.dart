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
    // ID 为 0 代表根目录
    if (event is StorageStarted) {
      yield StorageInProgress();
      try {
        List<Storage> results = await storageRepository.rootStorage();
        yield StorageRootResults(storages: results);
      } catch (e) {
        yield StorageStorageError(id: '0', message: e.message);
      }
    }

    if (event is StorageRefreshRoot) {
      yield StorageInProgress();
      try {
        List<Storage> results =
            await storageRepository.rootStorage(cache: false);
        yield StorageRootResults(storages: results);
      } catch (e) {
        yield StorageStorageError(id: '0', message: e.message);
      }
    }

    // 位置相关
    if (event is StorageStorageDetail) {
      yield StorageInProgress();
      try {
        Storage results = await storageRepository.storage(event.id);
        yield StorageStorageDetailResults(storage: results);
      } catch (e) {
        yield StorageStorageError(id: event.id, message: e.message);
      }
    }

    if (event is StorageRefreshStorageDetail) {
      yield StorageInProgress();
      try {
        Storage results =
            await storageRepository.storage(event.id, cache: false);
        yield StorageStorageDetailResults(storage: results);
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
        yield StorageUpdateStorageSuccess(id: event.id);
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
        if (event.parentId != null) {
          yield StorageAddStorageSuccess(parentId: event.parentId);
        } else {
          yield StorageAddStorageSuccess(parentId: '0');
        }
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
        await storageRepository.deleteStorage(id: event.storage.id);
        if (event.storage.parent != null) {
          yield StorageStorageDeleted(parentId: event.storage.parent.id);
        } else {
          yield StorageStorageDeleted(parentId: '0');
        }
        // 刷新受到影响的数据
        if (event.storage.parent != null) {
          add(StorageRefreshStorageDetail(id: event.storage.parent.id));
        } else {
          add(StorageRefreshRoot());
        }
        add(StorageRefreshStorages());
      } catch (e) {
        if (event.storage.parent != null) {
          yield StorageStorageError(
            parentId: event.storage.parent.id,
            message: e.message,
          );
        } else {
          yield StorageStorageError(
            parentId: '0',
            message: e.message,
          );
        }
      }
    }

    // 物品相关
    if (event is StorageItemDetail) {
      yield StorageInProgress();
      try {
        Item results = await storageRepository.item(event.id);
        yield StorageItemDetailResults(item: results);
      } catch (e) {
        yield StorageItemError(id: event.id, message: e.message);
      }
    }

    if (event is StorageRefreshItemDetail) {
      yield StorageInProgress();
      try {
        Item results = await storageRepository.item(event.id, cache: false);
        yield StorageItemDetailResults(item: results);
      } catch (e) {
        yield StorageItemError(id: event.id, message: e.message);
      }
    }

    if (event is StorageUpdateItem) {
      try {
        await storageRepository.updateItem(
          id: event.id,
          name: event.name,
          number: event.number,
          storageId: event.storageId,
          description: event.description,
          price: event.price,
          expirationDate: event.expirationDate,
        );
        yield StorageUpdateItemSuccess(id: event.id);
        // 刷新受到影响的存储的位置
        add(StorageRefreshItemDetail(id: event.id));
        add(StorageRefreshStorageDetail(id: event.storageId));
        add(StorageRefreshStorageDetail(id: event.oldStorageId));
      } catch (e) {
        yield StorageItemError(message: e.message);
      }
    }

    if (event is StorageAddItem) {
      try {
        await storageRepository.addItem(
          name: event.name,
          number: event.number,
          storageId: event.storageId,
          description: event.description,
          price: event.price,
          expirationDate: event.expirationDate,
        );
        yield StorageAddItemSuccess(storageId: event.storageId);
        // 刷新受到影响的存储的位置
        add(StorageRefreshStorageDetail(id: event.storageId));
      } catch (e) {
        yield StorageItemError(message: e.message);
      }
    }

    if (event is StorageDeleteItem) {
      yield StorageInProgress();
      try {
        await storageRepository.deleteItem(id: event.item.id);
        yield StorageItemDeleted(storageId: event.item.storage.id);
        // 刷新受到影响的数据
        add(StorageRefreshStorageDetail(id: event.item.storage.id));
      } catch (e) {
        yield StorageItemError(
          storageId: event.item.storage.id,
          message: e.message,
        );
      }
    }

    // 刷新所有位置的数据
    if (event is StorageRefreshStorages) {
      try {
        await storageRepository.storages(cache: false);
      } catch (e) {
        yield StorageStorageError(message: e.message);
      }
    }
  }
}
