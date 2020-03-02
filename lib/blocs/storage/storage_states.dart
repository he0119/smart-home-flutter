part of 'storage_bloc.dart';

abstract class StorageState extends Equatable {
  const StorageState();

  @override
  List<Object> get props => [];
}

class StorageInitial extends StorageState {}

class StorageSearchError extends StorageState {
  final OperationException errors;

  const StorageSearchError(this.errors);

  @override
  List<Object> get props => [errors];
}

class StorageSearchResults extends StorageState {
  final List<Item> items;
  final List<Storage> storages;

  StorageSearchResults(this.items, this.storages);

  @override
  List<Object> get props => [items, storages];
}
