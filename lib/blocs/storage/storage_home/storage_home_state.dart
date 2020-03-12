part of 'storage_home_bloc.dart';

abstract class StorageHomeState extends Equatable {
  const StorageHomeState();

  @override
  List<Object> get props => [];
}

class StorageHomeInitial extends StorageHomeState {}

class StorageHomeInProgress extends StorageHomeState {}

class StorageHomeError extends StorageHomeState {
  final String message;

  const StorageHomeError({@required this.message});

  @override
  List<Object> get props => [message];
}

class StorageHomeSuccess extends StorageHomeState {
  final List<Item> recentlyAddedItems;
  final List<Item> recentlyUpdatedItems;
  final List<Item> expiredItems;
  final List<Item> nearExpiredItems;

  const StorageHomeSuccess({
    this.recentlyAddedItems,
    this.recentlyUpdatedItems,
    this.expiredItems,
    this.nearExpiredItems,
  });

  @override
  List<Object> get props => [
        recentlyAddedItems,
        recentlyUpdatedItems,
        expiredItems,
        nearExpiredItems
      ];

  @override
  String toString() =>
      'StorageHomeSuccess { recentlyAddedItems ${recentlyAddedItems.length}, recentlyUpdatedItems ${recentlyUpdatedItems.length}, expiredItems ${expiredItems.length}, nearExpiredItems ${nearExpiredItems.length}, }';
}
