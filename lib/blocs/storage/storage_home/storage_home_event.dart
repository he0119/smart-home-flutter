part of 'storage_home_bloc.dart';

abstract class StorageHomeEvent extends Equatable {
  const StorageHomeEvent();

  @override
  List<Object> get props => [];
}

class StorageHomeFetched extends StorageHomeEvent {
  /// 物品的种类
  final ItemType itemType;

  /// 是否需要刷新，默认不需要
  final bool cache;

  const StorageHomeFetched({
    @required this.itemType,
    this.cache = true,
  });

  @override
  List<Object> get props => [itemType, cache];

  @override
  String toString() => 'StorageHomeFetched(itemType: $itemType, cache: $cache)';
}
