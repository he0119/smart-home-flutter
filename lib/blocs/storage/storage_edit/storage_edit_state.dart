part of 'storage_edit_bloc.dart';

abstract class StorageEditState extends Equatable {
  const StorageEditState();

  @override
  List<Object> get props => [];
}

class StorageEditInitial extends StorageEditState {}

class StorageEditInProgress extends StorageEditState {}

class StorageEditFailure extends StorageEditState {
  final String message;

  const StorageEditFailure(this.message);

  @override
  String toString() => 'StorageEditFailure { message: $message }';
}

class StorageAddSuccess extends StorageEditState {
  final Storage storage;

  const StorageAddSuccess({@required this.storage});

  @override
  String toString() => 'StorageAddSuccess { storage: ${storage.name} }';
}

class StorageUpdateSuccess extends StorageEditState {
  final Storage storage;

  const StorageUpdateSuccess({@required this.storage});

  @override
  String toString() => 'StorageUpdateSuccess { storage: ${storage.name} }';
}

class StorageDeleteSuccess extends StorageEditState {
  final Storage storage;

  const StorageDeleteSuccess({@required this.storage});

  @override
  String toString() => 'StorageDeleteSuccess { storage: ${storage.name} }';
}
