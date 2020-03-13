part of 'storage_detail_bloc.dart';

abstract class StorageDetailEvent extends Equatable {
  const StorageDetailEvent();

  @override
  List<Object> get props => [];
}

class StorageDetailRoot extends StorageDetailEvent {}

class StorageDetailRootRefreshed extends StorageDetailEvent {}

class StorageDetailChanged extends StorageDetailEvent {
  final String id;

  const StorageDetailChanged({@required this.id});

  @override
  List<Object> get props => [id];

  @override
  String toString() => 'StorageDetailChanged { id: $id }';
}

class StorageDetailRefreshed extends StorageDetailEvent {
  final String id;

  const StorageDetailRefreshed({@required this.id});

  @override
  List<Object> get props => [id];

  @override
  String toString() => 'StorageDetailRefreshed { id: $id }';
}

class StorageEditStarted extends StorageDetailEvent {
  final String id;

  const StorageEditStarted({@required this.id});

  @override
  List<Object> get props => [id];

  @override
  String toString() => 'StorageEditStarted { id: $id }';
}

class StorageAddStarted extends StorageDetailEvent {
  final String parentId;

  const StorageAddStarted({@required this.parentId});

  @override
  List<Object> get props => [parentId];

  @override
  String toString() => 'StorageAddStarted { id: $parentId }';
}

class StorageAdded extends StorageDetailEvent {
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

class StorageDeleted extends StorageDetailEvent {
  final Storage storage;

  const StorageDeleted({@required this.storage});

  @override
  List<Object> get props => [storage];

  @override
  String toString() => 'StorageDeleted { name: ${storage.name} }';
}

class StorageUpdated extends StorageDetailEvent {
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
