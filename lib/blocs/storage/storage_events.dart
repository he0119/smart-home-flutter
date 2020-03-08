part of 'storage_bloc.dart';

abstract class StorageEvent extends Equatable {
  const StorageEvent();

  @override
  List<Object> get props => [];
}

class StorageStarted extends StorageEvent {}

class StorageItemDetail extends StorageEvent {
  final String id;

  const StorageItemDetail(this.id);

  @override
  List<Object> get props => [id];

  @override
  String toString() => 'ItemDetail $id';
}

class StorageDeleteItem extends StorageEvent {
  final String id;

  const StorageDeleteItem(this.id);

  @override
  List<Object> get props => [id];

  @override
  String toString() => 'DeleteItem $id';
}

class StorageDeleteStorage extends StorageEvent {
  final String id;

  const StorageDeleteStorage(this.id);

  @override
  List<Object> get props => [id];

  @override
  String toString() => 'DeleteStorage $id';
}

class StorageStorageDetail extends StorageEvent {
  final String id;

  const StorageStorageDetail(this.id);

  @override
  List<Object> get props => [id];

  @override
  String toString() => 'StorageDetail $id';
}

class StorageRefreshItemDetail extends StorageEvent {
  final String id;

  const StorageRefreshItemDetail({@required this.id});

  @override
  List<Object> get props => [id];

  @override
  String toString() => 'RefreshItemDetail $id';
}

class StorageRefreshStorageDetail extends StorageEvent {
  final String id;

  const StorageRefreshStorageDetail({@required this.id});

  @override
  List<Object> get props => [id];

  @override
  String toString() => 'RefreshStorageDetail { id: $id }';
}

class StorageRefreshRoot extends StorageEvent {}

class StorageRefreshStorages extends StorageEvent {}

class StorageUpdateStorage extends StorageEvent {
  final String id;
  final String name;
  final String parentId;
  final String description;

  const StorageUpdateStorage({
    @required this.id,
    this.name,
    this.parentId,
    this.description,
  });

  @override
  List<Object> get props => [id, name, parentId, description];

  @override
  String toString() => 'UpdateStorage { id: $id }';
}

class StorageAddStorage extends StorageEvent {
  final String name;
  final String parentId;
  final String description;

  const StorageAddStorage({
    @required this.name,
    this.parentId,
    this.description,
  });

  @override
  List<Object> get props => [name, parentId, description];

  @override
  String toString() => 'AddStorage { name: $name }';
}

class StorageUpdateItem extends StorageEvent {
  final String id;
  final String name;
  final int number;
  final String storageId;
  final String description;
  final double price;
  final DateTime expirationDate;

  const StorageUpdateItem({
    @required this.id,
    this.name,
    this.number,
    this.storageId,
    this.description,
    this.price,
    this.expirationDate,
  });

  @override
  List<Object> get props =>
      [id, name, number, storageId, description, price, expirationDate];

  @override
  String toString() => 'UpdateItem { name: $name }';
}

class StorageAddItem extends StorageEvent {
  final String name;
  final int number;
  final String storageId;
  final String description;
  final double price;
  final DateTime expirationDate;

  const StorageAddItem({
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
  String toString() => 'AddItem { name: $name }';
}
