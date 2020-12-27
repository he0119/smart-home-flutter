part of 'storage_home_bloc.dart';

abstract class StorageHomeState extends Equatable {
  const StorageHomeState();

  @override
  List<Object> get props => [];
}

class StorageHomeInProgress extends StorageHomeState {
  @override
  String toString() => 'StorageHomeInProgress';
}

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
  String toString() =>
      'StorageHomeFailure(message: $message, itemType: $itemType)';
}

class StorageHomeSuccess extends StorageHomeState {
  final ItemType itemType;
  final List<Item> recentlyCreatedItems;
  final List<Item> recentlyEditedItems;
  final List<Item> expiredItems;
  final List<Item> nearExpiredItems;
  final PageInfo pageInfo;

  const StorageHomeSuccess({
    @required this.itemType,
    this.recentlyCreatedItems,
    this.recentlyEditedItems,
    this.expiredItems,
    this.nearExpiredItems,
    this.pageInfo,
  });

  bool get hasReachedMax => !pageInfo.hasNextPage;

  StorageHomeSuccess copyWith({
    ItemType itemType,
    List<Item> recentlyCreatedItems,
    List<Item> recentlyEditedItems,
    List<Item> expiredItems,
    List<Item> nearExpiredItems,
    PageInfo pageInfo,
  }) {
    return StorageHomeSuccess(
      itemType: itemType ?? this.itemType,
      recentlyCreatedItems: recentlyCreatedItems ?? this.recentlyCreatedItems,
      recentlyEditedItems: recentlyEditedItems ?? this.recentlyEditedItems,
      expiredItems: expiredItems ?? this.expiredItems,
      nearExpiredItems: nearExpiredItems ?? this.nearExpiredItems,
      pageInfo: pageInfo ?? this.pageInfo,
    );
  }

  @override
  List<Object> get props => [
        recentlyCreatedItems,
        recentlyEditedItems,
        expiredItems,
        nearExpiredItems,
        itemType,
        pageInfo,
      ];

  @override
  String toString() =>
      'StorageHomeSuccess(itemType: $itemType, hasReachedMax: $hasReachedMax)';
}
