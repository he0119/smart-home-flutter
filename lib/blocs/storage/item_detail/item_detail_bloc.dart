import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/repositories/storage_repository.dart';

part 'item_detail_event.dart';
part 'item_detail_state.dart';

class ItemDetailBloc extends Bloc<ItemDetailEvent, ItemDetailState> {
  final StorageRepository storageRepository;

  ItemDetailBloc({@required this.storageRepository})
      : super(ItemDetailInProgress());

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
        yield ItemDetailFailure(
          message: e.message,
          itemId: event.itemId,
        );
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
        yield ItemDetailFailure(
          message: e.message,
          itemId: event.itemId,
        );
      }
    }
  }
}
