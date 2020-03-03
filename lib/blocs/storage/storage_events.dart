part of 'storage_bloc.dart';

abstract class StorageEvent extends Equatable {
  const StorageEvent();

  @override
  List<Object> get props => [];
}

class StorageSearchStarted extends StorageEvent {}

class StorageSearchChanged extends StorageEvent {
  final String key;

  const StorageSearchChanged(this.key);

  @override
  List<Object> get props => [key];

  @override
  String toString() => key;
}
