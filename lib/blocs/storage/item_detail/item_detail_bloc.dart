import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/repositories/storage_repository.dart';

part 'item_detail_event.dart';
part 'item_detail_state.dart';

class ItemDetailBloc extends Bloc<ItemDetailEvent, ItemDetailState> {
  final StorageRepository storageRepository;

  ItemDetailBloc({
    @required this.storageRepository,
  }) : super(ItemDetailInProgress());

  @override
  Stream<ItemDetailState> mapEventToState(
    ItemDetailEvent event,
  ) async* {
    if (event is ItemDetailStarted) {
      try {
        Item item;
        // 如果有 id 则直接使用 id 查询，如果没有则使用名称查询
        if (event.itemId != null) {
          item = await storageRepository.item(id: event.itemId);
        } else {
          item = await storageRepository.itemByName(name: event.itemName);
          if (item == null) {
            yield ItemDetailFailure(
              '获取物品失败，物品不存在',
              itemName: event.itemName,
              itemId: event.itemId,
            );
            return;
          }
        }
        yield ItemDetailSuccess(item: item);
      } catch (e) {
        yield ItemDetailFailure(
          e?.message ?? e.toString(),
          itemName: event.itemName,
          itemId: event.itemId,
        );
      }
    }
    final currentState = state;
    if (event is ItemDetailRefreshed && currentState is ItemDetailSuccess) {
      yield ItemDetailInProgress();
      try {
        Item item = await storageRepository.item(
          id: currentState.item.id,
          cache: false,
        );
        yield ItemDetailSuccess(item: item);
      } catch (e) {
        yield ItemDetailFailure(
          e?.message ?? e.toString(),
          itemName: currentState.item.name,
          itemId: currentState.item.id,
        );
      }
    }
  }
}
