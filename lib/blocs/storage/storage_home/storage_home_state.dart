part of 'storage_home_bloc.dart';

abstract class StorageHomeState extends Equatable {
  const StorageHomeState();

  @override
  List<Object> get props => [];
}

class StorageHomeInProgress extends StorageHomeState {}

class StorageHomeError extends StorageHomeState {
  final String message;
  final ItemType itemType;

  const StorageHomeError({
    @required this.message,
    @required this.itemType,
  });

  @override
  List<Object> get props => [message, itemType];
}

class StorageHomeSuccess extends StorageHomeState {
  final List<Item> recentlyAddedItems;
  final List<Item> recentlyUpdatedItems;
  final List<Item> expiredItems;
  final List<Item> nearExpiredItems;
  final ItemType itemType;

  const StorageHomeSuccess(
      {this.recentlyAddedItems,
      this.recentlyUpdatedItems,
      this.expiredItems,
      this.nearExpiredItems,
      @required this.itemType});

  @override
  List<Object> get props => [
        recentlyAddedItems,
        recentlyUpdatedItems,
        expiredItems,
        nearExpiredItems
      ];

  @override
  String toString() =>
      'StorageHomeSuccess { recentlyAddedItems ${recentlyAddedItems?.length ?? 0}, recentlyUpdatedItems ${recentlyUpdatedItems?.length ?? 0}, expiredItems ${expiredItems?.length ?? 0}, nearExpiredItems ${nearExpiredItems?.length ?? 0}, }';
}
