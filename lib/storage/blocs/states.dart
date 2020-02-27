part of 'storage_bloc.dart';

abstract class StorageState extends Equatable {
  const StorageState();

  @override
  List<Object> get props => [];
}

class Initial extends StorageState {}

class SearchError extends StorageState {
  final OperationException errors;

  const SearchError(this.errors);

  @override
  List<Object> get props => [errors];
}

class SearchResults extends StorageState {
  final List<Item> items;
  final List<Storage> storage;

  const SearchResults(this.items, this.storage);

  @override
  List<Object> get props => [items, storage];
}
