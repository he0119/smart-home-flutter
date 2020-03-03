part of 'search_bloc.dart';

abstract class StorageSearchState extends Equatable {
  const StorageSearchState();

  @override
  List<Object> get props => [];
}

class StorageLoading extends StorageSearchState {}

class StorageError extends StorageSearchState {
  final String message;

  const StorageError(this.message);

  @override
  List<Object> get props => [message];
}

class StorageSearchResults extends StorageSearchState {
  final List<Item> items;
  final List<Storage> storages;

  StorageSearchResults(this.items, this.storages);

  @override
  List<Object> get props => [items, storages];
}