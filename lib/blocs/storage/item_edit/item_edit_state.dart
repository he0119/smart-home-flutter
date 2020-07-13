part of 'item_edit_bloc.dart';

abstract class ItemEditState extends Equatable {
  const ItemEditState();

  @override
  List<Object> get props => [];
}

class ItemEditInitial extends ItemEditState {}

class ItemEditInProgress extends ItemEditState {}

class ItemEditFailure extends ItemEditState {
  final String message;

  const ItemEditFailure(this.message);
}

class ItemAddSuccess extends ItemEditState {
  final Item item;

  const ItemAddSuccess({@required this.item});

  @override
  String toString() => 'ItemAddSuccess { item: ${item.name} }';
}

class ItemUpdateSuccess extends ItemEditState {
  final Item item;

  const ItemUpdateSuccess({@required this.item});

  @override
  String toString() => 'ItemUpdateSuccess { item: ${item.name} }';
}

class ItemDeleteSuccess extends ItemEditState {
  final Item item;

  const ItemDeleteSuccess({@required this.item});

  @override
  String toString() => 'ItemDeleteSuccess { item: ${item.name} }';
}
