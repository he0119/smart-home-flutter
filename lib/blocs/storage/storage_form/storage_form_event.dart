part of 'storage_form_bloc.dart';

abstract class StorageFormEvent extends Equatable {
  const StorageFormEvent();

  @override
  List<Object> get props => [];
}

class StorageFormStarted extends StorageFormEvent {}

class StorageNameChanged extends StorageFormEvent {
  final String name;

  const StorageNameChanged({@required this.name});

  @override
  List<Object> get props => [name];

  @override
  String toString() => 'StorageNameChanged { name: $name }';
}

class StorageParentChanged extends StorageFormEvent {
  final String parent;

  const StorageParentChanged({@required this.parent});

  @override
  List<Object> get props => [parent];

  @override
  String toString() => 'StorageParentChanged { parent_id: $parent }';
}

class StorageDescriptionChanged extends StorageFormEvent {
  final String description;

  const StorageDescriptionChanged({@required this.description});

  @override
  List<Object> get props => [description];

  @override
  String toString() =>
      'StorageDescriptionChanged { description: $description }';
}

class StorageFormSubmitted extends StorageFormEvent {
  final bool isEditing;
  final String id;
  final String oldParentId;

  const StorageFormSubmitted(
      {@required this.isEditing, this.id, this.oldParentId});

  @override
  List<Object> get props => [isEditing, id, oldParentId];

  @override
  String toString() => 'StorageFormSubmitted { item id: $id }';
}
