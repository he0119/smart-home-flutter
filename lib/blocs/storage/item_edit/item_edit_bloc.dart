import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'package:smart_home/models/models.dart';
import 'package:smart_home/repositories/repositories.dart';

part 'item_edit_event.dart';
part 'item_edit_state.dart';

class ItemEditBloc extends Bloc<ItemEditEvent, ItemEditState> {
  final StorageRepository storageRepository;

  ItemEditBloc({
    @required this.storageRepository,
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
          expiredAt: event.expiredAt,
        );
        yield ItemUpdateSuccess(item: item);
      } catch (e) {
        yield ItemEditFailure(e.message);
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
          expiredAt: event.expiredAt,
        );

        yield ItemAddSuccess(item: item);
      } catch (e) {
        yield ItemEditFailure(e.message);
      }
    }
    if (event is ItemDeleted) {
      yield ItemEditInProgress();
      try {
        await storageRepository.deleteItem(itemId: event.item.id);
        yield ItemDeleteSuccess(item: event.item);
      } catch (e) {
        yield ItemEditFailure(e.message);
      }
    }
    if (event is ItemRestored) {
      yield ItemEditInProgress();
      try {
        await storageRepository.restoreItem(itemId: event.item.id);
        yield ItemRestoreSuccess(item: event.item);
      } catch (e) {
        yield ItemEditFailure(e.message);
      }
    }
  }
}
