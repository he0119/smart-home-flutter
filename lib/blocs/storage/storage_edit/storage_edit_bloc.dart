import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/blocs/storage/blocs.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/repositories/repositories.dart';

part 'storage_edit_event.dart';
part 'storage_edit_state.dart';

class StorageEditBloc extends Bloc<StorageEditEvent, StorageEditState> {
  final StorageRepository storageRepository;
  final StorageDetailBloc storageDetailBloc;
  final SnackBarBloc snackBarBloc;

  StorageEditBloc({
    @required this.storageRepository,
    @required this.storageDetailBloc,
    @required this.snackBarBloc,
  }) : super(StorageEditInitial());

  @override
  Stream<StorageEditState> mapEventToState(
    StorageEditEvent event,
  ) async* {
    if (event is StorageUpdated) {
      yield StorageEditInProgress();
      try {
        await storageRepository.updateStorage(
          id: event.id,
          name: event.name,
          parentId: event.parentId,
          description: event.description,
        );
        storageDetailBloc.add(StorageDetailRefreshed(id: event.id));
        yield StorageUpdateSuccess();
        snackBarBloc.add(
          SnackBarChanged(
            position: SnackBarPosition.storageDetail,
            message: '修改成功',
            type: MessageType.info,
          ),
        );
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
        snackBarBloc.add(
          SnackBarChanged(
            position: SnackBarPosition.storageEdit,
            message: e.message,
            type: MessageType.error,
          ),
        );
      }
    }
    if (event is StorageAdded) {
      yield StorageEditInProgress();
      try {
        await storageRepository.addStorage(
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
        yield StorageAddSuccess();
        snackBarBloc.add(
          SnackBarChanged(
            position: SnackBarPosition.storageDetail,
            message: '${event.name} 添加成功',
            type: MessageType.info,
          ),
        );
        // 刷新受到影响的界面
        // 添加新位置之后，位置列表需要更新
        await storageRepository.storages(cache: false);
      } catch (e) {
        yield StorageEditFailure(e.message);
        snackBarBloc.add(
          SnackBarChanged(
            position: SnackBarPosition.storageEdit,
            message: e.message,
            type: MessageType.error,
          ),
        );
      }
    }
    if (event is StorageDeleted) {
      yield StorageEditInProgress();
      snackBarBloc.add(
        SnackBarChanged(
          position: SnackBarPosition.storageDetail,
          message: '正在删除...',
          type: MessageType.info,
          duration: 1,
        ),
      );
      try {
        await storageRepository.deleteStorage(id: event.storage.id);
        if (event.storage.parent != null) {
          storageDetailBloc
              .add(StorageDetailRefreshed(id: event.storage.parent.id));
        } else {
          storageDetailBloc.add(StorageDetailRootRefreshed());
        }
        yield StorageDeleteSuccess();
        snackBarBloc.add(
          SnackBarChanged(
            position: SnackBarPosition.storageDetail,
            message: '${event.storage.name} 删除成功',
            type: MessageType.info,
          ),
        );
        // 删除位置之后，位置列表需要更新
        await storageRepository.storages(cache: false);
      } catch (e) {
        yield StorageEditFailure(e.message);
        snackBarBloc.add(
          SnackBarChanged(
            position: SnackBarPosition.storageDetail,
            message: e.message,
            type: MessageType.error,
          ),
        );
      }
    }
  }
}
