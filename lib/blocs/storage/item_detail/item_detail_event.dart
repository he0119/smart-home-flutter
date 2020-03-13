part of 'item_detail_bloc.dart';

abstract class ItemDetailEvent extends Equatable {
  const ItemDetailEvent();

  @override
  List<Object> get props => [];
}

class ItemDetailChanged extends ItemDetailEvent {
  final String itemId;

  const ItemDetailChanged({@required this.itemId});

  @override
  List<Object> get props => [itemId];

  @override
  String toString() => 'ItemChanged { itemId: $itemId }';
}

class ItemDetailRefreshed extends ItemDetailEvent {
  final String itemId;

  const ItemDetailRefreshed({@required this.itemId});

  @override
  List<Object> get props => [itemId];

  @override
  String toString() => 'ItemRefreshed { itemId: $itemId }';
}

class ItemEditStarted extends ItemDetailEvent {
  final String itemId;

  const ItemEditStarted({@required this.itemId});

  @override
  List<Object> get props => [itemId];

  @override
  String toString() => 'ItemEditStarted { itemId: $itemId }';
}

class ItemUpdated extends ItemDetailEvent {
  final String id;
  final String name;
  final int number;
  final String storageId;
  final String oldStorageId;
  final String description;
  final double price;
  final DateTime expirationDate;

  const ItemUpdated({
    @required this.id,
    this.name,
    this.number,
    this.storageId,
    this.oldStorageId,
    this.description,
    this.price,
    this.expirationDate,
  });

  @override
  List<Object> get props => [
        id,
        name,
        number,
        storageId,
        oldStorageId,
        description,
        price,
        expirationDate
      ];

  @override
  String toString() => 'ItemUpdated { name: $name }';
}

class ItemAdded extends ItemDetailEvent {
  final String name;
  final int number;
  final String storageId;
  final String description;
  final double price;
  final DateTime expirationDate;

  const ItemAdded({
    @required this.name,
    @required this.number,
    @required this.storageId,
    this.description,
    this.price,
    this.expirationDate,
  });

  @override
  List<Object> get props =>
      [name, number, storageId, description, price, expirationDate];

  @override
  String toString() => 'ItemAdded { name: $name }';
}

class ItemDeleted extends ItemDetailEvent {
  final Item item;

  const ItemDeleted({@required this.item});

  @override
  List<Object> get props => [item];

  @override
  String toString() => 'DeleteItem { name: ${item.name} }';
}
