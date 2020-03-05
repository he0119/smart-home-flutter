part of 'item_form_bloc.dart';

abstract class ItemFormEvent extends Equatable {
  const ItemFormEvent();

  @override
  List<Object> get props => [];
}

class ItemFormStarted extends ItemFormEvent {}

class NameChanged extends ItemFormEvent {
  final String name;

  const NameChanged({@required this.name});

  @override
  List<Object> get props => [name];

  @override
  String toString() => 'NameChanged { name: $name }';
}

class NumberChanged extends ItemFormEvent {
  final String number;

  const NumberChanged({@required this.number});

  @override
  List<Object> get props => [number];

  @override
  String toString() => 'NumberChanged { number: $number }';
}

class StorageChanged extends ItemFormEvent {
  final Storage storage;

  const StorageChanged({@required this.storage});

  @override
  List<Object> get props => [storage];

  @override
  String toString() => 'StorageChanged { storage: ${storage.name} }';
}

class DescriptionChanged extends ItemFormEvent {
  final String description;

  const DescriptionChanged({@required this.description});

  @override
  List<Object> get props => [description];

  @override
  String toString() => 'DescriptionChanged { description: $description }';
}

class PriceChanged extends ItemFormEvent {
  final String price;

  const PriceChanged({@required this.price});

  @override
  List<Object> get props => [price];

  @override
  String toString() => 'PriceChanged { price: $price }';
}

class ExpirationDateChanged extends ItemFormEvent {
  final DateTime expirationDate;

  const ExpirationDateChanged({@required this.expirationDate});

  @override
  List<Object> get props => [expirationDate];

  @override
  String toString() =>
      'ExpirationDateChanged { expirationDate: $expirationDate }';
}

class FormSubmitted extends ItemFormEvent {
  final String id;

  const FormSubmitted({@required this.id});

  @override
  List<Object> get props => [id];

  @override
  String toString() => 'FormSubmitted { item id: $id }';
}

class FormReset extends ItemFormEvent {}
