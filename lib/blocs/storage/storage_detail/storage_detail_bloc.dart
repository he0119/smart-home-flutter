import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:smart_home/blocs/snack_bar/snack_bar_bloc.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/repositories/storage_repository.dart';

part 'storage_detail_event.dart';
part 'storage_detail_state.dart';

class StorageDetailBloc extends Bloc<StorageDetailEvent, StorageDetailState> {
  final SnackBarBloc snackBarBloc;

  StorageDetailBloc({@required this.snackBarBloc});

  @override
  StorageDetailState get initialState => StorageDetailInProgress();

  @override
  Stream<StorageDetailState> mapEventToState(
    StorageDetailEvent event,
  ) async* {
    if (event is StorageDetailRoot) {
      yield StorageDetailInProgress();
      try {
        List<Storage> results = await storageRepository.rootStorage();
        yield StorageDetailRootSuccess(storages: results);
      } catch (e) {
        yield StorageDetailError(message: e.message);
      }
    }
    if (event is StorageDetailRootRefreshed) {
      yield StorageDetailInProgress();
      try {
        List<Storage> results =
            await storageRepository.rootStorage(cache: false);
        yield StorageDetailRootSuccess(storages: results);
      } catch (e) {
        yield StorageDetailError(message: e.message);
      }
    }
    if (event is StorageDetailChanged) {
      yield StorageDetailInProgress();
      try {
        Storage results = await storageRepository.storage(id: event.id);
        yield StorageDetailSuccess(storage: results);
      } catch (e) {
        yield StorageDetailError(message: e.message);
      }
    }
    if (event is StorageDetailRefreshed) {
      yield StorageDetailInProgress();
      try {
        Storage results = await storageRepository.storage(
          id: event.id,
          cache: false,
        );
        yield StorageDetailSuccess(storage: results);
      } catch (e) {
        yield StorageDetailError(message: e.message);
      }
    }

    if (event is StorageEditStarted) {
      yield StorageDetailInProgress();
      try {
        Storage results = await storageRepository.storage(id: event.id);
        yield StorageEditInitial(storage: results);
      } catch (e) {
        yield StorageDetailError(message: e.message);
      }
    }

    if (event is StorageAddStarted) {
      yield StorageDetailInProgress();
      try {
        yield StorageAddInitial(parentId: event.parentId);
      } catch (e) {
        yield StorageDetailError(message: e.message);
      }
    }

    if (event is StorageUpdated) {
      try {
        Storage storage = await storageRepository.updateStorage(
          id: event.id,
          name: event.name,
          parentId: event.parentId,
          description: event.description,
        );
        yield StorageDetailSuccess(storage: storage);
        snackBarBloc.add(
          SnackBarChanged(
            position: SnackBarPosition.storage,
            message: '修改成功',
            type: MessageType.info,
          ),
        );
        // 刷新受到影响的存储位置
        // 上一级页面会受到影响
        // FIXME: 如果调整了上一级位置，则会影响两个地方
        await storageRepository.storage(id: event.parentId, cache: false);
      } catch (e) {
        snackBarBloc.add(
          SnackBarChanged(
            position: SnackBarPosition.storage,
            message: e.message,
            type: MessageType.error,
          ),
        );
      }
    }

    if (event is StorageAdded) {
      try {
        await storageRepository.addStorage(
          name: event.name,
          parentId: event.parentId,
          description: event.description,
        );
        if (event.parentId != null) {
          add(StorageDetailRefreshed(id: event.parentId));
        }
        else {
          add(StorageDetailRootRefreshed());
        }
        snackBarBloc.add(
          SnackBarChanged(
            position: SnackBarPosition.storage,
            message: '${event.name} 添加成功',
            type: MessageType.info,
          ),
        );
        // 刷新受到影响的存储位置
        // 添加新位置之后，位置列表需要更新
        await storageRepository.storages(cache: false);
      } catch (e) {
        snackBarBloc.add(
          SnackBarChanged(
            position: SnackBarPosition.storage,
            message: e.message,
            type: MessageType.error,
          ),
        );
      }
    }

    if (event is StorageDeleted) {
      try {
        await storageRepository.deleteStorage(id: event.storage.id);
        add(StorageDetailRefreshed(id: event.storage.parent.id));
        snackBarBloc.add(
          SnackBarChanged(
            position: SnackBarPosition.storage,
            message: '${event.storage.name} 删除成功',
            type: MessageType.info,
          ),
        );
      } catch (e) {
        snackBarBloc.add(
          SnackBarChanged(
            position: SnackBarPosition.storage,
            message: e.message,
            type: MessageType.error,
          ),
        );
      }
    }
  }
}
