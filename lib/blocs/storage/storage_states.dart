part of 'storage_bloc.dart';

abstract class StorageState extends Equatable {
  const StorageState();

  @override
  List<Object> get props => [];
}

class StorageInProgress extends StorageState {}

class StorageError extends StorageState {
  final String message;

  const StorageError(this.message);

  @override
  List<Object> get props => [message];
}

class StorageRootResults extends StorageState {
  final List<Storage> storages;

  StorageRootResults(this.storages);

  @override
  List<Object> get props => [storages];
}

class StorageStorageDetailResults extends StorageState {
  final Storage storage;

  StorageStorageDetailResults(this.storage);

  @override
  List<Object> get props => [storage];
}

class StorageItemDetailResults extends StorageState {
  final Item item;

  StorageItemDetailResults(this.item);

  @override
  List<Object> get props => [item];
}

class StorageUpdateStorageSuccess extends StorageState {
  final Storage storage;

  StorageUpdateStorageSuccess(this.storage);

  @override
  List<Object> get props => [storage];
}

class StorageUpdateItemSuccess extends StorageState {
  final Item item;

  StorageUpdateItemSuccess(this.item);

  @override
  List<Object> get props => [item];
}

class StorageAddStorageSuccess extends StorageState {
  final Storage storage;

  StorageAddStorageSuccess(this.storage);

  @override
  List<Object> get props => [storage];
}

class StorageAddItemSuccess extends StorageState {
  final Item item;

  StorageAddItemSuccess(this.item);

  @override
  List<Object> get props => [item];
}
