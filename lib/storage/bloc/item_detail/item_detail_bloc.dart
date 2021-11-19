import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smarthome/storage/model/storage.dart';
import 'package:smarthome/storage/repository/storage_repository.dart';
import 'package:smarthome/utils/exceptions.dart';

part 'item_detail_event.dart';
part 'item_detail_state.dart';

class ItemDetailBloc extends Bloc<ItemDetailEvent, ItemDetailState> {
  final StorageRepository storageRepository;

  ItemDetailBloc({
    required this.storageRepository,
  }) : super(ItemDetailInProgress()) {
    on<ItemDetailStarted>(_onItemDetailStarted);
    on<ItemDetailRefreshed>(_onItemDetailRefreshed);
  }

  FutureOr<void> _onItemDetailStarted(
      ItemDetailStarted event, Emitter<ItemDetailState> emit) async {
    try {
      final item = await storageRepository.item(
        id: event.id,
      );
      if (item == null) {
        emit(ItemDetailFailure(
          '获取物品失败，物品不存在',
          id: event.id,
        ));
        return;
      }
      emit(ItemDetailSuccess(item: item));
    } on MyException catch (e) {
      emit(ItemDetailFailure(
        e.message,
        id: event.id,
      ));
    }
  }

  FutureOr<void> _onItemDetailRefreshed(
      ItemDetailRefreshed event, Emitter<ItemDetailState> emit) async {
    final currentState = state;
    if (currentState is ItemDetailSuccess) {
      emit(ItemDetailInProgress());
      try {
        final item = await storageRepository.item(
          id: currentState.item.id,
          cache: false,
        );
        if (item == null) {
          emit(ItemDetailFailure(
            '获取物品失败，物品不存在',
            id: currentState.item.id,
          ));
          return;
        }
        emit(ItemDetailSuccess(item: item));
      } on MyException catch (e) {
        emit(ItemDetailFailure(
          e.message,
          id: currentState.item.id,
        ));
      }
    }
  }
}
