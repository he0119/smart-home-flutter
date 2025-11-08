part of 'search_bloc.dart';

abstract class StorageSearchState extends Equatable {
  const StorageSearchState();

  @override
  List<Object> get props => [];
}

class StorageSearchInitial extends StorageSearchState {
  @override
  String toString() => 'StorageSearchInitial';
}

class StorageSearchInProgress extends StorageSearchState {
  @override
  String toString() => 'StorageSearchInProgress';
}

class StorageSearchFailure extends StorageSearchState {
  final String message;

  const StorageSearchFailure(this.message);

  @override
  List<Object> get props => [message];

  @override
  String toString() => 'StorageSearchFailure(message: $message)';
}

class StorageSearchSuccess extends StorageSearchState {
  final List<Item> items;
  final List<Storage> storages;
  final String term;

  const StorageSearchSuccess({
    required this.items,
    required this.storages,
    required this.term,
  });

  @override
  List<Object> get props => [items, storages, term];

  @override
  String toString() =>
      'StorageSearchSuccess'
      '(items: ${items.length}, storages: ${storages.length}, term: $term)';
}
