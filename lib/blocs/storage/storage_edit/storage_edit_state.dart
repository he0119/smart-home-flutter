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
}

class StorageAddSuccess extends StorageEditState {}

class StorageUpdateSuccess extends StorageEditState {}

class StorageDeleteSuccess extends StorageEditState {}
