part of 'storage_bloc.dart';

abstract class StorageState extends Equatable {
  const StorageState();

  @override
  List<Object> get props => [];
}

class StorageInProgress extends StorageState {}

/// 位置相关错误
/// 如果是详情页面请求出错，则附带上 ID，以确认是哪个界面需要显示错误信息
/// 如果是在修改界面或者删除时则不需要附带 ID。
class StorageStorageError extends StorageState {
  final String id;
  final String message;

  const StorageStorageError({this.id, this.message});

  @override
  List<Object> get props => [id, message];

  @override
  String toString() => 'StorageError($id) { message: $message }';
}

/// 物品相关错误
/// 如果详情页面请求出错，则附带上 ID，以确认是哪个界面需要显示错误信息
/// 如果是在修改界面或者删除时则不需要附带 ID。
class StorageItemError extends StorageState {
  final String id;
  final String message;

  const StorageItemError({this.id, this.message});

  @override
  List<Object> get props => [id, message];

  @override
  String toString() => 'StorageItemError($id) { message: $message }';
}

class StorageRootResults extends StorageState {
  final List<Storage> storages;

  StorageRootResults(this.storages);

  @override
  List<Object> get props => [storages];
}

class StorageStorageDetailResults extends StorageState {
  final Storage storage;

  StorageStorageDetailResults(this.storage);

  @override
  List<Object> get props => [storage];
}

class StorageItemDetailResults extends StorageState {
  final Item item;

  StorageItemDetailResults(this.item);

  @override
  List<Object> get props => [item];
}

class StorageItemDeleted extends StorageState {
  final String id;

  StorageItemDeleted(this.id);

  @override
  List<Object> get props => [id];
}

class StorageStorageDeleted extends StorageState {
  final String id;

  StorageStorageDeleted(this.id);

  @override
  List<Object> get props => [id];
}

class StorageUpdateStorageSuccess extends StorageState {}

class StorageUpdateItemSuccess extends StorageState {}

class StorageAddStorageSuccess extends StorageState {}

class StorageAddItemSuccess extends StorageState {}
