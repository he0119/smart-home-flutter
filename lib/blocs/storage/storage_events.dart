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

class StorageRefreshRoot extends StorageEvent {}

class StorageRefreshStorages extends StorageEvent {}
