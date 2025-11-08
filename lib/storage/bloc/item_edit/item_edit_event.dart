part of 'item_edit_bloc.dart';

abstract class ItemEditEvent extends Equatable {
  const ItemEditEvent();

  @override
  List<Object> get props => [];
}

class ItemUpdated extends ItemEditEvent {
  final String id;
  final String? name;
  final int? number;
  final String? storageId;
  final String? oldStorageId;
  final String? description;
  final double? price;
  final DateTime? expiredAt;

  const ItemUpdated({
    required this.id,
    this.name,
    this.number,
    this.storageId,
    this.oldStorageId,
    this.description,
    this.price,
    this.expiredAt,
  });

  @override
  String toString() => 'ItemUpdated(id: $id)';
}

class ItemAdded extends ItemEditEvent {
  final String name;
  final int number;
  final String? storageId;
  final String? description;
  final double? price;
  final DateTime? expiredAt;

  const ItemAdded({
    required this.name,
    required this.number,
    required this.storageId,
    this.description,
    this.price,
    this.expiredAt,
  });

  @override
  String toString() => 'ItemAdded(name: $name, number: $number)';
}

class ItemDeleted extends ItemEditEvent {
  final Item item;

  const ItemDeleted({required this.item});

  @override
  String toString() => 'ItemDeleted(item: $item)';
}

class ItemRestored extends ItemEditEvent {
  final Item item;

  const ItemRestored({required this.item});

  @override
  String toString() => 'ItemRestored(item: $item)';
}

class ConsumableAdded extends ItemEditEvent {
  final Item item;
  final List<Item?> consumables;

  const ConsumableAdded({required this.item, required this.consumables});

  @override
  String toString() => 'ConsumableAdded(item: $item)';
}

class ConsumableDeleted extends ItemEditEvent {
  final Item item;
  final List<Item> consumables;

  const ConsumableDeleted({required this.item, required this.consumables});

  @override
  String toString() => 'ConsumableDeleted(item: $item)';
}
