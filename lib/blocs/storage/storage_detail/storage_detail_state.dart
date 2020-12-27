part of 'storage_detail_bloc.dart';

abstract class StorageDetailState extends Equatable {
  const StorageDetailState();

  @override
  List<Object> get props => [];
}

class StorageDetailInProgress extends StorageDetailState {
  @override
  String toString() => 'StorageDetailInProgress';
}

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
  final bool hasNextPage;
  final String itemEndCursor;
  final String stroageEndCursor;

  const StorageDetailSuccess({
    this.storages,
    this.storage,
    this.hasNextPage,
    this.itemEndCursor,
    this.stroageEndCursor,
  }) : assert(storages != null || storage != null);

  StorageDetailSuccess copyWith({
    List<Storage> storages,
    Storage storage,
    bool hasNextPage,
    String itemEndCursor,
    String stroageEndCursor,
  }) {
    return StorageDetailSuccess(
      storages: storages ?? this.storages,
      storage: storage ?? this.storage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      itemEndCursor: itemEndCursor ?? this.itemEndCursor,
      stroageEndCursor: stroageEndCursor ?? this.stroageEndCursor,
    );
  }

  @override
  List<Object> get props => [storages, storage, hasNextPage];

  @override
  String toString() {
    return 'StorageDetailSuccess(storage: $storage, hasNextPage: $hasNextPage';
  }
}
