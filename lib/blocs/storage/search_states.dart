part of 'search_bloc.dart';

abstract class StorageSearchState extends Equatable {
  const StorageSearchState();

  @override
  List<Object> get props => [];
}

class StorageSearchLoading extends StorageSearchState {}

class StorageSearchError extends StorageSearchState {
  final String message;

  const StorageSearchError(this.message);

  @override
  List<Object> get props => [message];
}

class StorageSearchResults extends StorageSearchState {
  final List<Item> items;
  final List<Storage> storages;
  final String term;

  StorageSearchResults({
    @required this.items,
    @required this.storages,
    @required this.term,
  });

  @override
  List<Object> get props => [items, storages, term];
}
