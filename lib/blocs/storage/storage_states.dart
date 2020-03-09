part of 'storage_bloc.dart';

abstract class StorageState extends Equatable {
  const StorageState();

  @override
  List<Object> get props => [];
}

class StorageInProgress extends StorageState {}

class StorageRootResults extends StorageState {
  final List<Storage> storages;

  StorageRootResults({this.storages});

  @override
  List<Object> get props => [storages];
}

class StorageStorageDetailResults extends StorageState {
  final Storage storage;

  StorageStorageDetailResults({this.storage});

  @override
  List<Object> get props => [storage];
}

class StorageItemDetailResults extends StorageState {
  final Item item;

  StorageItemDetailResults({this.item});

  @override
  List<Object> get props => [item];
}

/// 位置相关错误
/// 如果是详情页面请求出错，则附带上 ID，以确认是哪个界面需要显示错误信息
/// 如果是在修改界面时则不需要附带 ID
/// 删除时如果出错则带上上一级 ID
class StorageStorageError extends StorageState {
  final String id;
  final String parentId;
  final String message;

  const StorageStorageError({this.id, this.parentId, this.message});

  @override
  List<Object> get props => [id, parentId, message];

  @override
  String toString() => 'StorageError($id or $parentId) { message: $message }';
}

/// 物品相关错误
/// 如果详情页面请求出错，则附带上 ID，以确认是哪个界面需要显示错误信息
/// 如果是在修改界面则不需要附带 ID
/// 删除时如果出错则带上 StorageId
class StorageItemError extends StorageState {
  final String id;
  final String storageId;
  final String message;

  const StorageItemError({this.id, this.storageId, this.message});

  @override
  List<Object> get props => [id, storageId, message];

  @override
  String toString() =>
      'StorageItemError($id or $storageId) { message: $message }';
}

class StorageStorageDeleted extends StorageState {
  final String parentId;

  StorageStorageDeleted({this.parentId});

  @override
  List<Object> get props => [parentId];
}

class StorageItemDeleted extends StorageState {
  final String id;
  final String storageId;

  StorageItemDeleted({this.id, this.storageId});

  @override
  List<Object> get props => [id, storageId];
}

class StorageUpdateStorageSuccess extends StorageState {
  final String id;

  StorageUpdateStorageSuccess({this.id});

  @override
  List<Object> get props => [id];
}

class StorageUpdateItemSuccess extends StorageState {
  final String id;

  StorageUpdateItemSuccess({this.id});

  @override
  List<Object> get props => [id];
}

class StorageAddStorageSuccess extends StorageState {
  final String parentId;

  StorageAddStorageSuccess({this.parentId});

  @override
  List<Object> get props => [parentId];
}

class StorageAddItemSuccess extends StorageState {
  final String id;
  final String storageId;

  StorageAddItemSuccess({this.id, this.storageId});

  @override
  List<Object> get props => [id, storageId];
}
