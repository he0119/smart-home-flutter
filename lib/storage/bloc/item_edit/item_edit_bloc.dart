import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smarthome/storage/model/storage.dart';
import 'package:smarthome/storage/repository/storage_repository.dart';
import 'package:smarthome/utils/exceptions.dart';

part 'item_edit_event.dart';
part 'item_edit_state.dart';

class ItemEditBloc extends Bloc<ItemEditEvent, ItemEditState> {
  final StorageRepository storageRepository;

  ItemEditBloc({required this.storageRepository}) : super(ItemEditInitial()) {
    on<ItemUpdated>(_onItemUpdated);
    on<ItemAdded>(_onItemAdded);
    on<ItemDeleted>(_onItemDeleted);
    on<ItemRestored>(_onItemRestored);
    on<ConsumableAdded>(_onConsumableAdded);
    on<ConsumableDeleted>(_onConsumableDeleted);
  }

  FutureOr<void> _onItemUpdated(
    ItemUpdated event,
    Emitter<ItemEditState> emit,
  ) async {
    emit(ItemEditInProgress());
    try {
      final item = await storageRepository.updateItem(
        id: event.id,
        name: event.name,
        number: event.number,
        storageId: event.storageId,
        description: event.description,
        price: event.price,
        expiredAt: event.expiredAt,
      );
      emit(ItemUpdateSuccess(item: item));
    } on MyException catch (e) {
      emit(ItemEditFailure(e.message));
    }
  }

  FutureOr<void> _onItemAdded(
    ItemAdded event,
    Emitter<ItemEditState> emit,
  ) async {
    emit(ItemEditInProgress());
    try {
      final item = await storageRepository.addItem(
        name: event.name,
        number: event.number,
        storageId: event.storageId,
        description: event.description,
        price: event.price,
        expiredAt: event.expiredAt,
      );

      emit(ItemAddSuccess(item: item));
    } on MyException catch (e) {
      emit(ItemEditFailure(e.message));
    }
  }

  FutureOr<void> _onItemDeleted(
    ItemDeleted event,
    Emitter<ItemEditState> emit,
  ) async {
    emit(ItemEditInProgress());
    try {
      await storageRepository.deleteItem(itemId: event.item.id);
      emit(ItemDeleteSuccess(item: event.item));
    } on MyException catch (e) {
      emit(ItemEditFailure(e.message));
    }
  }

  FutureOr<void> _onItemRestored(
    ItemRestored event,
    Emitter<ItemEditState> emit,
  ) async {
    emit(ItemEditInProgress());
    try {
      await storageRepository.restoreItem(itemId: event.item.id);
      emit(ItemRestoreSuccess(item: event.item));
    } on MyException catch (e) {
      emit(ItemEditFailure(e.message));
    }
  }

  FutureOr<void> _onConsumableAdded(
    ConsumableAdded event,
    Emitter<ItemEditState> emit,
  ) async {
    emit(ItemEditInProgress());
    try {
      final item = await storageRepository.addConsumable(
        id: event.item.id,
        consumableIds: event.consumables.map((e) => e!.id).toList(),
      );
      emit(ConsumableAddSuccess(item: item));
    } on MyException catch (e) {
      emit(ItemEditFailure(e.message));
    }
  }

  FutureOr<void> _onConsumableDeleted(
    ConsumableDeleted event,
    Emitter<ItemEditState> emit,
  ) async {
    emit(ItemEditInProgress());
    try {
      final item = await storageRepository.deleteConsumable(
        id: event.item.id,
        consumableIds: event.consumables.map((e) => e.id).toList(),
      );
      emit(ConsumableDeleteSuccess(item: item));
    } on MyException catch (e) {
      emit(ItemEditFailure(e.message));
    }
  }
}
