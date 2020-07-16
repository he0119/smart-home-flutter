part of 'search_bloc.dart';

abstract class StorageSearchState extends Equatable {
  const StorageSearchState();

  @override
  List<Object> get props => [];
}

class StorageSearchInProgress extends StorageSearchState {}

class StorageSearchFailure extends StorageSearchState {
  final String message;

  const StorageSearchFailure(this.message);

  @override
  List<Object> get props => [message];

  @override
  String toString() => 'StorageSearchFailure { message: $message }';
}

class StorageSearchSuccess extends StorageSearchState {
  final List<Item> items;
  final List<Storage> storages;
  final String term;

  StorageSearchSuccess({
    @required this.items,
    @required this.storages,
    @required this.term,
  });

  @override
  List<Object> get props => [items, storages, term];
}
