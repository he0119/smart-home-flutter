import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:smart_home/blocs/storage/item_detail/item_detail_bloc.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/repositories/storage_repository.dart';

part 'item_form_event.dart';
part 'item_form_state.dart';

class ItemFormBloc extends Bloc<ItemFormEvent, ItemFormState> {
  final StorageRepository storageRepository;
  final ItemDetailBloc itemDetailBloc;

  ItemFormBloc({
    @required this.storageRepository,
    @required this.itemDetailBloc,
  }) : super(ItemFormState.initial());

  @override
  Stream<ItemFormState> mapEventToState(
    ItemFormEvent event,
  ) async* {
    if (event is ItemFormStarted) {
      yield state.copyWith(listofStorages: await storageRepository.storages());
    }
    if (event is NameChanged) {
      yield state.copyWith(
        name: event.name,
        isNameValid: _isNameValid(event.name),
      );
    }
    if (event is NumberChanged) {
      yield state.copyWith(
        number: event.number,
        isNumberValid: _isNumberValid(event.number),
      );
    }
    if (event is PriceChanged) {
      yield state.copyWith(
        price: event.price,
        isPriceValid: _isPriceValid(event.price),
      );
    }
    if (event is DescriptionChanged) {
      yield state.copyWith(
        description: event.description,
        isDescriptionValid: true,
      );
    }
    if (event is StorageChanged) {
      yield state.copyWith(
        storage: event.storage,
        isStorageValid: _isStorageValid(event.storage),
      );
    }
    if (event is ExpirationDateChanged) {
      yield ItemFormState(
        name: state.name,
        isNameValid: state.isNameValid,
        number: state.number,
        isNumberValid: state.isNumberValid,
        description: state.description,
        isDescriptionValid: state.isDescriptionValid,
        expirationDate: event.expirationDate,
        isExpirationDateValid: true,
        price: state.price,
        isPriceValid: state.isPriceValid,
        storage: state.storage,
        isStorageValid: state.isStorageValid,
        listofStorages: state.listofStorages,
      );
    }
    if (event is FormSubmitted) {
      double price;
      if (state.price != null && state.price.isNotEmpty) {
        price = double.parse(state.price);
      } else {
        price = null;
      }
      if (event.isEditing) {
        itemDetailBloc.add(ItemUpdated(
          id: event.id,
          name: state.name,
          number: int.parse(state.number),
          storageId: state.storage,
          oldStorageId: event.oldStorageId,
          description: state.description,
          price: price,
          expirationDate: state.expirationDate?.toUtc(),
        ));
      } else {
        itemDetailBloc.add(ItemAdded(
          name: state.name,
          number: int.parse(state.number),
          storageId: state.storage,
          description: state.description,
          price: price,
          expirationDate: state.expirationDate?.toUtc(),
        ));
      }
    }
  }

  bool _isNameValid(String name) {
    return name.isNotEmpty;
  }

  bool _isNumberValid(String number) {
    return number.isNotEmpty;
  }

  bool _isPriceValid(String price) {
    if (price.isEmpty) return true;
    final parts = price.split('.');
    if (parts.length > 2) {
      return false;
    }
    if (parts[0].length > 8) {
      return false;
    }
    if (parts.length == 2 && parts[1].length > 2) {
      return false;
    }
    return true;
  }

  bool _isStorageValid(String storage) {
    return true;
  }
}
