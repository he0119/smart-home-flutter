part of 'storage_edit_bloc.dart';

abstract class StorageEditEvent extends Equatable {
  const StorageEditEvent();

  @override
  List<Object> get props => [];
}

class StorageAdded extends StorageEditEvent {
  final String name;
  final String parentId;
  final String description;

  const StorageAdded({
    @required this.name,
    this.parentId,
    this.description,
  });

  @override
  List<Object> get props => [name, parentId, description];

  @override
  String toString() => 'StorageAdded { name: $name }';
}

class StorageDeleted extends StorageEditEvent {
  final Storage storage;

  const StorageDeleted({@required this.storage});

  @override
  List<Object> get props => [storage];

  @override
  String toString() => 'StorageDeleted { name: ${storage.name} }';
}

class StorageUpdated extends StorageEditEvent {
  final String id;
  final String name;
  final String parentId;
  final String oldParentId;
  final String description;

  const StorageUpdated({
    @required this.id,
    this.name,
    this.parentId,
    this.oldParentId,
    this.description,
  });

  @override
  List<Object> get props => [id, name, parentId, oldParentId, description];

  @override
  String toString() => 'StorageUpdated { id: $id }';
}
