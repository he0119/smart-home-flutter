part of 'storage_bloc.dart';

abstract class StorageEvent extends Equatable {
  const StorageEvent();

  @override
  List<Object> get props => [];
}

class StorageRoot extends StorageEvent {}

class StorageItemDetail extends StorageEvent {
  final String key;

  const StorageItemDetail(this.key);

  @override
  List<Object> get props => [key];

  @override
  String toString() => key;
}

class StorageStorageDetail extends StorageEvent {
  final String id;

  const StorageStorageDetail(this.id);

  @override
  List<Object> get props => [id];

  @override
  String toString() => id;
}
