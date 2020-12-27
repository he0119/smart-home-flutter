part of 'storage_detail_bloc.dart';

abstract class StorageDetailState extends Equatable {
  const StorageDetailState();

  @override
  List<Object> get props => [];
}

class StorageDetailInitial extends StorageDetailState {}

class StorageDetailFailure extends StorageDetailState {
  final String message;
  final String name;
  final String id;

  const StorageDetailFailure(
    this.message, {
    @required this.name,
    this.id,
  });

  @override
  List<Object> get props => [message, name, id];

  @override
  String toString() => 'StorageDetailFailure(message: $message)';
}

class StorageDetailSuccess extends StorageDetailState {
  /// 家 这个页面所需数据
  final List<Storage> storages;

  /// 其他位置页面所需数据
  final Storage storage;
  final PageInfo itemPageInfo;
  final PageInfo storagePageInfo;

  const StorageDetailSuccess({
    this.storages,
    this.storage,
    this.itemPageInfo,
    this.storagePageInfo,
  }) : assert(storages != null || storage != null);

  bool get hasReachedMax =>
      !itemPageInfo.hasNextPage && !storagePageInfo.hasNextPage;

  StorageDetailSuccess copyWith({
    List<Storage> storages,
    Storage storage,
    PageInfo itemPageInfo,
    PageInfo storagePageInfo,
  }) {
    return StorageDetailSuccess(
      storages: storages ?? this.storages,
      storage: storage ?? this.storage,
      itemPageInfo: itemPageInfo ?? this.itemPageInfo,
      storagePageInfo: storagePageInfo ?? this.storagePageInfo,
    );
  }

  @override
  List<Object> get props => [storages, storage, itemPageInfo, storagePageInfo];

  @override
  String toString() {
    return 'StorageDetailSuccess(storage: $storage, hasReachedMax: $hasReachedMax)';
  }
}
