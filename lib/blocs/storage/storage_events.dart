part of 'storage_bloc.dart';

abstract class StorageEvent extends Equatable {
  const StorageEvent();

  @override
  List<Object> get props => [];
}

class StorageStarted extends StorageEvent {}

class StorageRefreshRoot extends StorageEvent {}

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
