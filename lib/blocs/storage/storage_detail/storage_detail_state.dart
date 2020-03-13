part of 'storage_detail_bloc.dart';

abstract class StorageDetailState extends Equatable {
  const StorageDetailState();

  @override
  List<Object> get props => [];
}

class StorageDetailInProgress extends StorageDetailState {}

class StorageDetailError extends StorageDetailState {
  final String message;

  const StorageDetailError({@required this.message});

  @override
  List<Object> get props => [message];
}

class StorageDetailRootSuccess extends StorageDetailState {
  final List<Storage> storages;

  const StorageDetailRootSuccess({@required this.storages});

  @override
  List<Object> get props => [storages];

  @override
  String toString() =>
      'StorageDetailRootSuccess { number: ${storages.length} }';
}

class StorageDetailSuccess extends StorageDetailState {
  final Storage storage;
  final List<Storage> ancestors;

  const StorageDetailSuccess(
      {@required this.storage, @required this.ancestors});

  @override
  List<Object> get props => [storage, ancestors];

  @override
  String toString() => 'StorageDetailSuccess { storage: ${storage.name} }';
}

class StorageEditInitial extends StorageDetailState {
  final Storage storage;

  const StorageEditInitial({@required this.storage});

  @override
  List<Object> get props => [storage];

  @override
  String toString() => 'StorageEditInitial { storage: ${storage.name} }';
}

class StorageAddInitial extends StorageDetailState {
  final String parentId;

  const StorageAddInitial({@required this.parentId});

  @override
  List<Object> get props => [parentId];

  @override
  String toString() => 'StorageAddInitial { parentId: $parentId }';
}

class StorageDeleteSuccess extends StorageDetailState {}
