part of 'storage_home_bloc.dart';

abstract class StorageHomeState extends Equatable {
  const StorageHomeState();

  @override
  List<Object> get props => [];
}

class StorageHomeInProgress extends StorageHomeState {}

class StorageHomeFailure extends StorageHomeState {
  final String message;
  final ItemType itemType;

  const StorageHomeFailure(
    this.message, {
    @required this.itemType,
  });

  @override
  List<Object> get props => [message, itemType];

  @override
  String toString() => 'StorageHomeFailure { message: $message }';
}

class StorageHomeSuccess extends StorageHomeState {
  final List<Item> recentlyCreatedItems;
  final List<Item> recentlyEditedItems;
  final List<Item> expiredItems;
  final List<Item> nearExpiredItems;
  final ItemType itemType;

  const StorageHomeSuccess(
      {this.recentlyCreatedItems,
      this.recentlyEditedItems,
      this.expiredItems,
      this.nearExpiredItems,
      @required this.itemType});

  @override
  List<Object> get props => [
        recentlyCreatedItems,
        recentlyEditedItems,
        expiredItems,
        nearExpiredItems
      ];

  @override
  String toString() =>
      'StorageHomeSuccess { recentlyCreatedItems ${recentlyCreatedItems?.length ?? 0}, recentlyEditedItems ${recentlyEditedItems?.length ?? 0}, expiredItems ${expiredItems?.length ?? 0}, nearExpiredItems ${nearExpiredItems?.length ?? 0}, }';
}
