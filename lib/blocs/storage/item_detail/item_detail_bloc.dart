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
    if (event is ItemAddStarted) {
      yield ItemDetailInProgress();
      try {
        yield ItemAddInitial(storageId: event.storageId);
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
          SnackBarChanged(
            position: SnackBarPosition.item,
            message: '修改成功',
            type: MessageType.info,
          ),
        );
        await storageRepository.storage(id: event.oldStorageId, cache: false);
      } catch (e) {
        snackBarBloc.add(
          SnackBarChanged(
            position: SnackBarPosition.item,
            message: e.message,
            type: MessageType.error,
          ),
        );
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
        yield ItemAddSuccess(item: item);
        snackBarBloc.add(
          SnackBarChanged(
            position: SnackBarPosition.storage,
            message: '${item.name} 添加成功',
            type: MessageType.info,
          ),
        );
      } catch (e) {
        snackBarBloc.add(
          SnackBarChanged(
            position: SnackBarPosition.item,
            message: e.message,
            type: MessageType.error,
          ),
        );
      }
    }

    if (event is ItemDeleted) {
      try {
        await storageRepository.deleteItem(id: event.item.id);
        yield ItemDeleteSuccess(item: event.item);
        snackBarBloc.add(
          SnackBarChanged(
            position: SnackBarPosition.storage,
            message: '${event.item.name} 删除成功',
            type: MessageType.info,
          ),
        );
      } catch (e) {
        snackBarBloc.add(
          SnackBarChanged(
            position: SnackBarPosition.item,
            message: e.message,
            type: MessageType.error,
          ),
        );
      }
    }
  }
}
