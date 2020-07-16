import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/blocs/storage/blocs.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/repositories/repositories.dart';

part 'item_edit_event.dart';
part 'item_edit_state.dart';

class ItemEditBloc extends Bloc<ItemEditEvent, ItemEditState> {
  final StorageRepository storageRepository;
  final SnackBarBloc snackBarBloc;
  final ItemDetailBloc itemDetailBloc;
  final StorageHomeBloc storageHomeBloc;
  final StorageDetailBloc storageDetailBloc;
  final StorageSearchBloc storageSearchBloc;
  final String searchKeyword;

  ItemEditBloc({
    @required this.storageRepository,
    @required this.snackBarBloc,
    this.itemDetailBloc,
    this.storageHomeBloc,
    this.storageDetailBloc,
    this.storageSearchBloc,
    this.searchKeyword,
  }) : super(ItemEditInitial());

  @override
  Stream<ItemEditState> mapEventToState(
    ItemEditEvent event,
  ) async* {
    if (event is ItemUpdated) {
      yield ItemEditInProgress();
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
        itemDetailBloc.add(ItemDetailRefreshed(itemId: item.id));
        yield ItemUpdateSuccess(item: item);
        snackBarBloc.add(
          SnackBarChanged(
            position: SnackBarPosition.itemDetail,
            message: '修改成功',
            type: MessageType.info,
          ),
        );
        // 刷新受影响的页面
        // 从位置详情界面进入，修改后会影响物品详情界面的显示
        // 调整了物品位置后，需要重新刷新位置详情界面
        if (storageDetailBloc != null) {
          if (event.storageId == event.oldStorageId) {
            storageDetailBloc.add(StorageDetailChanged(id: event.storageId));
          } else {
            storageDetailBloc.add(StorageDetailRefreshed(id: event.storageId));
            await storageRepository.storage(
              id: event.oldStorageId,
              cache: false,
            );
          }
        }
        // 从物品管理主页进入
        if (storageHomeBloc != null) {
          storageHomeBloc.add(StorageHomeChanged(itemType: ItemType.all));
        }
        // 从搜索界面进入
        if (storageSearchBloc != null) {
          storageSearchBloc.add(StorageSearchChanged(key: searchKeyword));
        }
      } catch (e) {
        yield ItemEditFailure(e.message);
        snackBarBloc.add(
          SnackBarChanged(
            position: SnackBarPosition.itemEdit,
            message: e.message,
            type: MessageType.error,
          ),
        );
      }
    }
    if (event is ItemAdded) {
      yield ItemEditInProgress();
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
            position: SnackBarPosition.storageDetail,
            message: '${item.name} 添加成功',
            type: MessageType.info,
          ),
        );
        // 刷新位置详情界面
        assert(storageDetailBloc != null);
        storageDetailBloc.add(StorageDetailRefreshed(id: event.storageId));
      } catch (e) {
        yield ItemEditFailure(e.message);
        snackBarBloc.add(
          SnackBarChanged(
            position: SnackBarPosition.itemEdit,
            message: e.message,
            type: MessageType.error,
          ),
        );
      }
    }
    if (event is ItemDeleted) {
      yield ItemEditInProgress();
      snackBarBloc.add(
        SnackBarChanged(
          position: SnackBarPosition.itemDetail,
          message: '正在删除',
          type: MessageType.info,
        ),
      );
      try {
        await storageRepository.deleteItem(id: event.item.id);
        yield ItemDeleteSuccess(item: event.item);
        snackBarBloc.add(
          SnackBarChanged(
            position: SnackBarPosition.storageDetail,
            message: '${event.item.name} 删除成功',
            type: MessageType.info,
          ),
        );
        // 刷新受影响的页面
        if (storageHomeBloc != null) {
          storageHomeBloc.add(StorageHomeRefreshed(itemType: ItemType.all));
        }
        if (storageDetailBloc != null) {
          storageDetailBloc
              .add(StorageDetailRefreshed(id: event.item.storage.id));
        }
        if (storageSearchBloc != null) {
          storageSearchBloc.add(StorageSearchChanged(key: searchKeyword));
        }
      } catch (e) {
        yield ItemEditFailure(e.message);
        snackBarBloc.add(
          SnackBarChanged(
            position: SnackBarPosition.itemDetail,
            message: e.message,
            type: MessageType.error,
          ),
        );
      }
    }
  }
}