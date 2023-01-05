part of 'search_bloc.dart';

abstract class StorageSearchEvent extends Equatable {
  const StorageSearchEvent();

  @override
  List<Object> get props => [];
}

class StorageSearchChanged extends StorageSearchEvent {
  final String key;
  final bool isDeleted;
  final bool missingStorage;

  const StorageSearchChanged({
    required this.key,
    this.isDeleted = false,
    this.missingStorage = false,
  });

  @override
  List<Object> get props => [key];

  @override
  String toString() => 'StorageSearchChanged(key: $key)';
}
