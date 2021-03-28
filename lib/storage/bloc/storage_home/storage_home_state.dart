part of 'storage_home_bloc.dart';

abstract class StorageHomeState extends Equatable {
  const StorageHomeState();

  @override
  List<Object?> get props => [];
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
    required this.itemType,
  });

  @override
  List<Object> get props => [message, itemType];

  @override
  String toString() =>
      'StorageHomeFailure(message: $message, itemType: $itemType)';
}

class StorageHomeSuccess extends StorageHomeState {
  final ItemType itemType;
  final List<Item>? recentlyCreatedItems;
  final List<Item>? recentlyEditedItems;
  final List<Item>? expiredItems;
  final List<Item>? nearExpiredItems;
  final PageInfo pageInfo;

  const StorageHomeSuccess({
    required this.itemType,
    this.recentlyCreatedItems,
    this.recentlyEditedItems,
    this.expiredItems,
    this.nearExpiredItems,
    required this.pageInfo,
  });

  bool get hasReachedMax => !pageInfo.hasNextPage;

  int get itemCount {
    var count = 0;
    if (recentlyCreatedItems != null) count += recentlyCreatedItems!.length;
    if (recentlyEditedItems != null) count += recentlyEditedItems!.length;
    if (expiredItems != null) count += expiredItems!.length;
    if (nearExpiredItems != null) count += nearExpiredItems!.length;
    return count;
  }

  @override
  List<Object?> get props => [
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
