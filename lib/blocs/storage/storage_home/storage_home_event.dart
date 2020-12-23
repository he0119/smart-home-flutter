part of 'storage_home_bloc.dart';

abstract class StorageHomeEvent {
  const StorageHomeEvent();
}

class StorageHomeChanged extends StorageHomeEvent {
  final ItemType itemType;
  final bool refresh;

  const StorageHomeChanged({
    @required this.itemType,
    this.refresh = false,
  });

  @override
  String toString() =>
      'StorageHomeChanged { itemType: $itemType, refresh: $refresh }';
}
