part of 'storage_bloc.dart';

abstract class StorageEvent extends Equatable {
  const StorageEvent();

  @override
  List<Object> get props => [];
}

class Start extends StorageEvent {}

class StartSearch extends StorageEvent {
  final String key;

  const StartSearch(this.key);

  @override
  List<Object> get props => [key];

  @override
  String toString() => key;
}
