import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smarthome/storage/model/storage.dart';
import 'package:smarthome/storage/repository/storage_repository.dart';
import 'package:smarthome/utils/exceptions.dart';

part 'item_edit_event.dart';
part 'item_edit_state.dart';

class ItemEditBloc extends Bloc<ItemEditEvent, ItemEditState> {
  final StorageRepository storageRepository;

  ItemEditBloc({
    required this.storageRepository,
  }) : super(ItemEditInitial());

  @override
  Stream<ItemEditState> mapEventToState(
    ItemEditEvent event,
  ) async* {
    if (event is ItemUpdated) {
      yield ItemEditInProgress();
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
        yield ItemUpdateSuccess(item: item);
      } on MyException catch (e) {
        yield ItemEditFailure(e.message);
      }
    }
    if (event is ItemAdded) {
      yield ItemEditInProgress();
      try {
        final item = await storageRepository.addItem(
          name: event.name,
          number: event.number,
          storageId: event.storageId,
          description: event.description,
          price: event.price,
          expiredAt: event.expiredAt,
        );

        yield ItemAddSuccess(item: item);
      } on MyException catch (e) {
        yield ItemEditFailure(e.message);
      }
    }
    if (event is ItemDeleted) {
      yield ItemEditInProgress();
      try {
        await storageRepository.deleteItem(itemId: event.item.id);
        yield ItemDeleteSuccess(item: event.item);
      } on MyException catch (e) {
        yield ItemEditFailure(e.message);
      }
    }
    if (event is ItemRestored) {
      yield ItemEditInProgress();
      try {
        await storageRepository.restoreItem(itemId: event.item.id);
        yield ItemRestoreSuccess(item: event.item);
      } on MyException catch (e) {
        yield ItemEditFailure(e.message);
      }
    }
    if (event is ConsumableAdded) {
      yield ItemEditInProgress();
      try {
        final item = await storageRepository.addConsumable(
            id: event.item.id,
            consumableIds: event.consumables.map((e) => e!.id).toList());
        yield ConsumableAddSuccess(item: item);
      } on MyException catch (e) {
        yield ItemEditFailure(e.message);
      }
    }
    if (event is ConsumableDeleted) {
      yield ItemEditInProgress();
      try {
        final item = await storageRepository.deleteConsumable(
            id: event.item.id,
            consumableIds: event.consumables.map((e) => e.id).toList());
        yield ConsumableDeleteSuccess(item: item);
      } on MyException catch (e) {
        yield ItemEditFailure(e.message);
      }
    }
  }
}
