part of 'item_edit_bloc.dart';

abstract class ItemEditEvent extends Equatable {
  const ItemEditEvent();

  @override
  List<Object> get props => [];
}

class ItemUpdated extends ItemEditEvent {
  final String id;
  final String name;
  final int number;
  final String storageId;
  final String oldStorageId;
  final String description;
  final double price;
  final DateTime expiredAt;

  const ItemUpdated({
    @required this.id,
    this.name,
    this.number,
    this.storageId,
    this.oldStorageId,
    this.description,
    this.price,
    this.expiredAt,
  });

  @override
  String toString() => 'ItemUpdated { name: $name }';
}

class ItemAdded extends ItemEditEvent {
  final String name;
  final int number;
  final String storageId;
  final String description;
  final double price;
  final DateTime expiredAt;

  const ItemAdded({
    @required this.name,
    @required this.number,
    @required this.storageId,
    this.description,
    this.price,
    this.expiredAt,
  });

  @override
  String toString() => 'ItemAdded { name: $name }';
}

class ItemDeleted extends ItemEditEvent {
  final Item item;

  const ItemDeleted({@required this.item});

  @override
  String toString() => 'DeleteItem { name: ${item.name} }';
}

class ItemRestored extends ItemEditEvent {
  final Item item;

  const ItemRestored({@required this.item});

  @override
  String toString() => 'RestoreItem { name: ${item.name} }';
}
