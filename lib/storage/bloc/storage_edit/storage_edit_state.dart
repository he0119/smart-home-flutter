part of 'storage_edit_bloc.dart';

abstract class StorageEditState extends Equatable {
  const StorageEditState();

  @override
  List<Object> get props => [];
}

class StorageEditInitial extends StorageEditState {
  @override
  String toString() => 'StorageEditInitial';
}

class StorageEditInProgress extends StorageEditState {
  @override
  String toString() => 'StorageEditInProgress';
}

class StorageEditFailure extends StorageEditState {
  final String message;

  const StorageEditFailure(this.message);

  @override
  String toString() => 'StorageEditFailure(message: $message)';
}

class StorageAddSuccess extends StorageEditState {
  final Storage storage;

  const StorageAddSuccess({required this.storage});

  @override
  String toString() => 'StorageAddSuccess(storage: $storage)';
}

class StorageUpdateSuccess extends StorageEditState {
  final Storage storage;

  const StorageUpdateSuccess({required this.storage});

  @override
  String toString() => 'StorageUpdateSuccess(storage: $storage)';
}

class StorageDeleteSuccess extends StorageEditState {
  final Storage storage;

  const StorageDeleteSuccess({required this.storage});

  @override
  String toString() => 'StorageDeleteSuccess(storage: $storage)';
}
