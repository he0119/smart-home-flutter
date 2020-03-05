import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:smart_home/models/models.dart';

part 'item_form_event.dart';
part 'item_form_state.dart';

class ItemFormBloc extends Bloc<ItemFormEvent, ItemFormState> {
  @override
  ItemFormState get initialState => ItemFormState.initial();

  @override
  Stream<ItemFormState> mapEventToState(
    ItemFormEvent event,
  ) async* {
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
  }

  bool _isNameValid(String name) {
    return name != '';
  }

  bool _isNumberValid(String number) {
    return number != '';
  }

  bool _isPriceValid(String price) {
    if (price == '') return true;
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
}
