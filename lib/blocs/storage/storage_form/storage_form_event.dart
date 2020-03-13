part of 'storage_form_bloc.dart';

abstract class StorageFormEvent extends Equatable {
  const StorageFormEvent();

  @override
  List<Object> get props => [];
}

class StorageFormStarted extends StorageFormEvent {}

class NameChanged extends StorageFormEvent {
  final String name;

  const NameChanged({@required this.name});

  @override
  List<Object> get props => [name];

  @override
  String toString() => 'NameChanged { name: $name }';
}

class ParentChanged extends StorageFormEvent {
  final String parent;

  const ParentChanged({@required this.parent});

  @override
  List<Object> get props => [parent];

  @override
  String toString() => 'ParentChanged { parent_id: $parent }';
}

class DescriptionChanged extends StorageFormEvent {
  final String description;

  const DescriptionChanged({@required this.description});

  @override
  List<Object> get props => [description];

  @override
  String toString() => 'DescriptionChanged { description: $description }';
}

class FormSubmitted extends StorageFormEvent {
  final bool isEditing;
  final String id;
  final String oldParentId;

  const FormSubmitted({@required this.isEditing, this.id, this.oldParentId});

  @override
  List<Object> get props => [isEditing, id, oldParentId];

  @override
  String toString() => 'FormSubmitted { item id: $id }';
}
