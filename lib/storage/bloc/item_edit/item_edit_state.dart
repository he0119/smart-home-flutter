part of 'item_edit_bloc.dart';

abstract class ItemEditState extends Equatable {
  const ItemEditState();

  @override
  List<Object> get props => [];
}

class ItemEditInitial extends ItemEditState {
  @override
  String toString() => 'ItemEditInitial';
}

class ItemEditInProgress extends ItemEditState {
  @override
  String toString() => 'ItemEditInProgress';
}

class ItemEditFailure extends ItemEditState {
  final String message;

  const ItemEditFailure(this.message);

  @override
  String toString() => 'ItemEditFailure(message: $message)';
}

class ItemAddSuccess extends ItemEditState {
  final Item item;

  const ItemAddSuccess({required this.item});

  @override
  String toString() => 'ItemAddSuccess(item: $item)';
}

class ItemUpdateSuccess extends ItemEditState {
  final Item item;

  const ItemUpdateSuccess({required this.item});

  @override
  String toString() => 'ItemUpdateSuccess(item: $item)';
}

class ItemDeleteSuccess extends ItemEditState {
  final Item item;

  const ItemDeleteSuccess({required this.item});

  @override
  String toString() => 'ItemDeleteSuccess(item: $item)';
}

class ItemRestoreSuccess extends ItemEditState {
  final Item item;

  const ItemRestoreSuccess({required this.item});

  @override
  String toString() => 'ItemRestoreSuccess(item: $item)';
}

class ConsumableAddSuccess extends ItemEditState {
  final Item item;

  const ConsumableAddSuccess({required this.item});

  @override
  String toString() => 'ConsumableAddSuccess(item: $item)';
}

class ConsumableDeleteSuccess extends ItemEditState {
  final Item item;

  const ConsumableDeleteSuccess({required this.item});

  @override
  String toString() => 'ConsumableDeleteSuccess(item: $item)';
}
