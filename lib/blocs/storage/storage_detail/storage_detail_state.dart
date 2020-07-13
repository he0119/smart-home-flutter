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

  const StorageDetailFailure({
    @required this.message,
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
  final Storage storage;
  final List<Storage> ancestors;
  final bool backImmediately;

  const StorageDetailSuccess({
    @required this.storage,
    @required this.ancestors,
    @required this.backImmediately,
  });

  @override
  String toString() => 'StorageDetailSuccess { storage: ${storage.name} }';
}
