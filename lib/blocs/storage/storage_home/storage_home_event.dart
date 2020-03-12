part of 'storage_home_bloc.dart';

abstract class StorageHomeEvent extends Equatable {
  const StorageHomeEvent();

  @override
  List<Object> get props => [];
}

class StorageHomeStarted extends StorageHomeEvent {}

class StorageHomeRefreshed extends StorageHomeEvent {
  final ItemType itemType;

  const StorageHomeRefreshed({@required this.itemType});

  @override
  List<Object> get props => [itemType];

  @override
  String toString() => 'StorageHomeRefreshed { itemType: $itemType }';
}

class StorageHomeChanged extends StorageHomeEvent {
  final ItemType itemType;

  const StorageHomeChanged({@required this.itemType});

  @override
  List<Object> get props => [itemType];

  @override
  String toString() => 'StorageHomeChanged { itemType: $itemType }';
}
