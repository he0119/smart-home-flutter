part of 'storage_bloc.dart';

abstract class StorageState extends Equatable {
  const StorageState();

  @override
  List<Object> get props => [];
}

class StorageInitial extends StorageState {}

class StorageLoading extends StorageState {}

class StorageError extends StorageState {
  final String message;

  const StorageError(this.message);

  @override
  List<Object> get props => [message];
}

class StorageSearchResults extends StorageState {
  final List<Item> items;
  final List<Storage> storages;

  StorageSearchResults(this.items, this.storages);

  @override
  List<Object> get props => [items, storages];
}
