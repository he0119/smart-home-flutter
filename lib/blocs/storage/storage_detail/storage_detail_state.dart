part of 'storage_detail_bloc.dart';

abstract class StorageDetailState {
  const StorageDetailState();
}

class StorageDetailInProgress extends StorageDetailState {
  @override
  String toString() => 'StorageDetailInProgress';
}

class StorageDetailFailure extends StorageDetailState {
  final String message;
  final String storageId;

  const StorageDetailFailure(
    this.message, {
    @required this.storageId,
  });

  @override
  String toString() => 'StorageDetailFailure { message: $message }';
}

class StorageDetailRootSuccess extends StorageDetailState {
  final List<Storage> storages;

  const StorageDetailRootSuccess({@required this.storages});

  @override
  String toString() =>
      'StorageDetailRootSuccess { number: ${storages.length} }';
}

class StorageDetailSuccess extends StorageDetailState {
  final bool backImmediately;
  final Storage storage;
  final List<Storage> ancestors;
  final bool hasNextPage;
  final String itemEndCursor;
  final String stroageEndCursor;

  const StorageDetailSuccess({
    this.backImmediately,
    this.storage,
    this.ancestors,
    this.hasNextPage,
    this.itemEndCursor,
    this.stroageEndCursor,
  });

  StorageDetailSuccess copyWith({
    bool backImmediately,
    Storage storage,
    List<Storage> ancestors,
    bool hasNextPage,
    String itemEndCursor,
    String stroageEndCursor,
  }) {
    return StorageDetailSuccess(
      backImmediately: backImmediately ?? this.backImmediately,
      storage: storage ?? this.storage,
      ancestors: ancestors ?? this.ancestors,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      itemEndCursor: itemEndCursor ?? this.itemEndCursor,
      stroageEndCursor: stroageEndCursor ?? this.stroageEndCursor,
    );
  }

  @override
  String toString() => 'StorageDetailSuccess { storage: ${storage.name} }';
}
