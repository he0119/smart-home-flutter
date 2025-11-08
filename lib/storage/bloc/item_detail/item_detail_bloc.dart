import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smarthome/storage/model/storage.dart';
import 'package:smarthome/storage/repository/storage_repository.dart';
import 'package:smarthome/utils/exceptions.dart';

part 'item_detail_event.dart';
part 'item_detail_state.dart';

enum ItemDetailStatus { initial, loading, success, failure }

class ItemDetailBloc extends Bloc<ItemDetailEvent, ItemDetailState> {
  final StorageRepository storageRepository;

  ItemDetailBloc({required this.storageRepository})
    : super(const ItemDetailState()) {
    on<ItemDetailStarted>(_onItemDetailStarted);
    on<ItemDetailRefreshed>(_onItemDetailRefreshed);
  }

  FutureOr<void> _onItemDetailStarted(
    ItemDetailStarted event,
    Emitter<ItemDetailState> emit,
  ) async {
    try {
      final item = await storageRepository.item(id: event.id);
      if (item == null) {
        emit(
          state.copyWith(
            status: ItemDetailStatus.failure,
            error: '获取物品失败，物品不存在',
          ),
        );
        return;
      }
      emit(state.copyWith(status: ItemDetailStatus.success, item: item));
    } on MyException catch (e) {
      emit(state.copyWith(status: ItemDetailStatus.failure, error: e.message));
    }
  }

  FutureOr<void> _onItemDetailRefreshed(
    ItemDetailRefreshed event,
    Emitter<ItemDetailState> emit,
  ) async {
    if (state.status == ItemDetailStatus.success) {
      emit(state.copyWith(status: ItemDetailStatus.loading));
      try {
        final item = await storageRepository.item(
          id: state.item.id,
          cache: false,
        );
        if (item == null) {
          emit(
            state.copyWith(
              status: ItemDetailStatus.failure,
              error: '获取物品失败，物品不存在',
            ),
          );
          return;
        }
        emit(state.copyWith(status: ItemDetailStatus.success, item: item));
      } on MyException catch (e) {
        emit(
          state.copyWith(status: ItemDetailStatus.failure, error: e.message),
        );
      }
    }
  }
}
