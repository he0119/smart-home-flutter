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

  const StorageRefreshItemDetail(this.id);

  @override
  List<Object> get props => [id];

  @override
  String toString() => 'RefreshItemDetail $id';
}

class StorageRefreshStorageDetail extends StorageEvent {
  final String id;

  const StorageRefreshStorageDetail(this.id);

  @override
  List<Object> get props => [id];

  @override
  String toString() => 'RefreshStorageDetail $id';
}

class StorageAddStorage extends StorageEvent {
  final Storage storage;

  const StorageAddStorage(this.storage);

  @override
  List<Object> get props => [storage];
}

class StorageAddItem extends StorageEvent {
  final Item item;

  const StorageAddItem(this.item);

  @override
  List<Object> get props => [item];
}

class StorageUpdateStorage extends StorageEvent {
  final Storage storage;

  const StorageUpdateStorage(this.storage);

  @override
  List<Object> get props => [storage];
}

class StorageUpdateItem extends StorageEvent {
  final Item item;

  const StorageUpdateItem(this.item);

  @override
  List<Object> get props => [item];
}
