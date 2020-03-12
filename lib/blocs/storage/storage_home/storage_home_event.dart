part of 'storage_home_bloc.dart';

abstract class StorageHomeEvent extends Equatable {
  const StorageHomeEvent();

  @override
  List<Object> get props => [];
}

class StorageHomeStarted extends StorageHomeEvent {}

class StorageHomeRefreshed extends StorageHomeEvent {}
