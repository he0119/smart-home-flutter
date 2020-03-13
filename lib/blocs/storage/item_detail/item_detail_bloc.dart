import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/repositories/storage_repository.dart';

part 'item_detail_event.dart';
part 'item_detail_state.dart';

class ItemDetailBloc extends Bloc<ItemDetailEvent, ItemDetailState> {
  final SnackBarBloc snackBarBloc;

  ItemDetailBloc({@required this.snackBarBloc});

  @override
  ItemDetailState get initialState => ItemDetailInProgress();

  @override
  Stream<ItemDetailState> mapEventToState(
    ItemDetailEvent event,
  ) async* {
    if (event is ItemDetailChanged) {
      yield ItemDetailInProgress();
      try {
        Item results = await storageRepository.item(id: event.itemId);
        yield ItemDetailSuccess(item: results);
      } catch (e) {
        yield ItemDetailError(message: e.message);
      }
    }
    if (event is ItemDetailRefreshed) {
      yield ItemDetailInProgress();
      try {
        Item results = await storageRepository.item(
          id: event.itemId,
          cache: false,
        );
        yield ItemDetailSuccess(item: results);
      } catch (e) {
        yield ItemDetailError(message: e.message);
      }
    }

    if (event is ItemEditStarted) {
      yield ItemDetailInProgress();
      try {
        Item results = await storageRepository.item(id: event.itemId);
        yield ItemEditInitial(item: results);
      } catch (e) {
        yield ItemDetailError(message: e.message);
      }
    }

    if (event is ItemUpdated) {
      try {
        Item item = await storageRepository.updateItem(
          id: event.id,
          name: event.name,
          number: event.number,
          storageId: event.storageId,
          description: event.description,
          price: event.price,
          expirationDate: event.expirationDate,
        );
        yield ItemDetailSuccess(item: item);
        snackBarBloc.add(
          SnackBarChanged(message: '修改成功', messageType: MessageType.info),
        );
        // 刷新受到影响的存储的位置
        // add(StorageRefreshItemDetail(id: event.id));
        // add(StorageRefreshStorageDetail(id: event.storageId));
        // add(StorageRefreshStorageDetail(id: event.oldStorageId));
      } catch (e) {
        yield ItemDetailError(message: e.message);
      }
    }

    if (event is ItemAdded) {
      try {
        Item item = await storageRepository.addItem(
          name: event.name,
          number: event.number,
          storageId: event.storageId,
          description: event.description,
          price: event.price,
          expirationDate: event.expirationDate,
        );
        yield ItemDetailSuccess(item: item);
        // 刷新受到影响的存储的位置
        // add(StorageRefreshStorageDetail(id: event.storageId));
      } catch (e) {
        yield ItemDetailError(message: e.message);
      }
    }

    if (event is ItemDeleted) {
      try {
        await storageRepository.deleteItem(id: event.item.id);
        yield ItemDeleteSuccess();
        // 刷新受到影响的数据
        // add(StorageRefreshStorageDetail(id: event.item.storage.id));
      } catch (e) {
        yield ItemDetailError(message: e.message);
      }
    }
  }
}
