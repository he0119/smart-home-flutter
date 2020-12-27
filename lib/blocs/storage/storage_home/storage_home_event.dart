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
  final bool refresh;

  const StorageHomeFetched({
    @required this.itemType,
    this.refresh = false,
  });

  @override
  List<Object> get props => [itemType, refresh];

  @override
  String toString() =>
      'StorageHomeFetched(itemType: $itemType, refresh: $refresh)';
}
