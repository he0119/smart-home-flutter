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

  @override
  String toString() => 'StorageError { message: $message}';
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

class StorageItemDeleted extends StorageState {
  final String id;

  StorageItemDeleted(this.id);

  @override
  List<Object> get props => [id];
}

class StorageStorageDeleted extends StorageState {
  final String id;

  StorageStorageDeleted(this.id);

  @override
  List<Object> get props => [id];
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
