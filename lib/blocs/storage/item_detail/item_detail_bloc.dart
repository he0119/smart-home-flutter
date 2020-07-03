import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/blocs/storage/blocs.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/repositories/graphql_api_client.dart';
import 'package:smart_home/repositories/storage_repository.dart';

part 'item_detail_event.dart';
part 'item_detail_state.dart';

class ItemDetailBloc extends Bloc<ItemDetailEvent, ItemDetailState> {
  final SnackBarBloc snackBarBloc;
  final StorageHomeBloc storageHomeBloc;
  final StorageDetailBloc storageDetailBloc;
  final StorageSearchBloc storageSearchBloc;
  final String searchKeyword;

  ItemDetailBloc({
    @required this.snackBarBloc,
    this.storageHomeBloc,
    this.storageDetailBloc,
    this.storageSearchBloc,
    this.searchKeyword,
  }) : super(ItemDetailInProgress()) {
    if (storageSearchBloc != null) {
      assert(searchKeyword != null, '请提供搜索关键词');
    }
  }

  @override
  Stream<ItemDetailState> mapEventToState(
    ItemDetailEvent event,
  ) async* {
    if (event is ItemDetailChanged) {
      yield ItemDetailInProgress();
      try {
        Item results = await storageRepository.item(id: event.itemId);
        yield ItemDetailSuccess(item: results);
      } on GraphQLApiException catch (e) {
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
      } on GraphQLApiException catch (e) {
        yield ItemDetailError(message: e.message);
      }
    }

    if (event is ItemEditStarted) {
      yield ItemDetailInProgress();
      try {
        Item results = await storageRepository.item(id: event.itemId);
        yield ItemEditInitial(item: results);
      } on GraphQLApiException catch (e) {
        yield ItemDetailError(message: e.message);
      }
    }
    if (event is ItemAddStarted) {
      yield ItemDetailInProgress();
      try {
        yield ItemAddInitial(storageId: event.storageId);
      } on GraphQLApiException catch (e) {
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
        // 受影响的页面
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
        if (storageHomeBloc != null) {
          storageHomeBloc.add(StorageHomeChanged(itemType: ItemType.all));
        }
        if (storageSearchBloc != null) {
          storageSearchBloc.add(StorageSearchChanged(key: searchKeyword));
        }
      } on GraphQLApiException catch (e) {
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
        // 更新位置详情界面
        assert(storageDetailBloc != null);
        storageDetailBloc.add(StorageDetailRefreshed(id: event.storageId));
      } on GraphQLApiException catch (e) {
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
      } on GraphQLApiException catch (e) {
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
