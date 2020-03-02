part of 'storage_bloc.dart';

abstract class StorageEvent extends Equatable {
  const StorageEvent();

  @override
  List<Object> get props => [];
}

class StorageSearch extends StorageEvent {
  final String key;

  const StorageSearch(this.key);

  @override
  List<Object> get props => [key];

  @override
  String toString() => key;
}
