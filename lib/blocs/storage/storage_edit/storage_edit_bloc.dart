import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_home/blocs/storage/blocs.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/repositories/repositories.dart';

part 'storage_edit_event.dart';
part 'storage_edit_state.dart';

class StorageEditBloc extends Bloc<StorageEditEvent, StorageEditState> {
  final StorageRepository storageRepository;
  final StorageDetailBloc storageDetailBloc;

  StorageEditBloc({
    @required this.storageRepository,
    @required this.storageDetailBloc,
  }) : super(StorageEditInitial());

  @override
  Stream<StorageEditState> mapEventToState(
    StorageEditEvent event,
  ) async* {
    if (event is StorageUpdated) {
      yield StorageEditInProgress();
      try {
        Storage storage = await storageRepository.updateStorage(
          id: event.id,
          name: event.name,
          parentId: event.parentId,
          description: event.description,
        );
        storageDetailBloc.add(StorageDetailRefreshed(id: event.id));
        yield StorageUpdateSuccess(storage: storage);
        // 刷新受到影响的存储位置
        // 上一级页面和以前的上一级页面会受到影响。
        if (event.parentId != null) {
          await storageRepository.storage(id: event.parentId, cache: false);
        } else {
          await storageRepository.rootStorage(cache: false);
        }
        if (event.oldParentId != null && event.oldParentId != event.parentId) {
          await storageRepository.storage(id: event.oldParentId, cache: false);
        } else {
          await storageRepository.rootStorage(cache: false);
        }
      } catch (e) {
        yield StorageEditFailure(e.message);
      }
    }
    if (event is StorageAdded) {
      yield StorageEditInProgress();
      try {
        Storage storage = await storageRepository.addStorage(
          name: event.name,
          parentId: event.parentId,
          description: event.description,
        );
        // 刷新受影响的界面
        if (event.parentId != null) {
          storageDetailBloc.add(StorageDetailRefreshed(id: event.parentId));
        } else {
          storageDetailBloc.add(StorageDetailRootRefreshed());
        }
        yield StorageAddSuccess(storage: storage);
        // 刷新受到影响的界面
        // 添加新位置之后，位置列表需要更新
        await storageRepository.storages(cache: false);
      } catch (e) {
        yield StorageEditFailure(e.message);
      }
    }
    if (event is StorageDeleted) {
      yield StorageEditInProgress();
      try {
        await storageRepository.deleteStorage(storageId: event.storage.id);
        if (event.storage.parent != null) {
          storageDetailBloc
              .add(StorageDetailRefreshed(id: event.storage.parent.id));
        } else {
          storageDetailBloc.add(StorageDetailRootRefreshed());
        }
        yield StorageDeleteSuccess(storage: event.storage);
        // 删除位置之后，位置列表需要更新
        await storageRepository.storages(cache: false);
      } catch (e) {
        yield StorageEditFailure(e.message);
      }
    }
  }
}
