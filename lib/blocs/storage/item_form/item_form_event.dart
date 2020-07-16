part of 'item_form_bloc.dart';

abstract class ItemFormEvent extends Equatable {
  const ItemFormEvent();

  @override
  List<Object> get props => [];
}

class ItemFormStarted extends ItemFormEvent {}

class ItemNameChanged extends ItemFormEvent {
  final String name;

  const ItemNameChanged({@required this.name});

  @override
  List<Object> get props => [name];

  @override
  String toString() => 'ItemNameChanged { name: $name }';
}

class ItemNumberChanged extends ItemFormEvent {
  final String number;

  const ItemNumberChanged({@required this.number});

  @override
  List<Object> get props => [number];

  @override
  String toString() => 'ItemNumberChanged { number: $number }';
}

class ItemStorageChanged extends ItemFormEvent {
  final String storage;

  const ItemStorageChanged({@required this.storage});

  @override
  List<Object> get props => [storage];

  @override
  String toString() => 'ItemStorageChanged { storage_id: $storage }';
}

class ItemDescriptionChanged extends ItemFormEvent {
  final String description;

  const ItemDescriptionChanged({@required this.description});

  @override
  List<Object> get props => [description];

  @override
  String toString() => 'ItemDescriptionChanged { description: $description }';
}

class ItemPriceChanged extends ItemFormEvent {
  final String price;

  const ItemPriceChanged({@required this.price});

  @override
  List<Object> get props => [price];

  @override
  String toString() => 'ItemPriceChanged { price: $price }';
}

class ItemExpirationDateChanged extends ItemFormEvent {
  final DateTime expirationDate;

  const ItemExpirationDateChanged({@required this.expirationDate});

  @override
  List<Object> get props => [expirationDate];

  @override
  String toString() =>
      'ItemExpirationDateChanged { expirationDate: $expirationDate }';
}

class ItemFormSubmitted extends ItemFormEvent {
  final bool isEditing;
  final String id;
  final String oldStorageId;

  const ItemFormSubmitted(
      {@required this.isEditing, this.id, this.oldStorageId});

  @override
  List<Object> get props => [isEditing, id, oldStorageId];

  @override
  String toString() => 'ItemFormSubmitted { item id: $id }';
}
