part of 'search_bloc.dart';

abstract class StorageSearchEvent extends Equatable {
  const StorageSearchEvent();

  @override
  List<Object> get props => [];
}

class StorageSearchChanged extends StorageSearchEvent {
  final String key;

  const StorageSearchChanged(this.key);

  @override
  List<Object> get props => [key];

  @override
  String toString() => key;
}
