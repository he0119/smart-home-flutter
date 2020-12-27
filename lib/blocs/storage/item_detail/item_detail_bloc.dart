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
        final item = await storageRepository.item(
          name: event.name,
          id: event.id,
        );
        if (item == null) {
          yield ItemDetailFailure(
            '获取物品失败，物品不存在',
            name: event.name,
            id: event.id,
          );
          return;
        }
        yield ItemDetailSuccess(item: item);
      } catch (e) {
        yield ItemDetailFailure(
          e.message,
          name: event.name,
          id: event.id,
        );
      }
    }
    final currentState = state;
    if (event is ItemDetailRefreshed && currentState is ItemDetailSuccess) {
      yield ItemDetailInProgress();
      try {
        Item item = await storageRepository.item(
          name: currentState.item.name,
          id: currentState.item.id,
          cache: false,
        );
        yield ItemDetailSuccess(item: item);
      } catch (e) {
        yield ItemDetailFailure(
          e.message,
          name: currentState.item.name,
          id: currentState.item.id,
        );
      }
    }
  }
}
