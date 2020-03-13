part of 'item_detail_bloc.dart';

abstract class ItemDetailState extends Equatable {
  const ItemDetailState();

  @override
  List<Object> get props => [];
}

class ItemDetailInProgress extends ItemDetailState {}

class ItemDetailError extends ItemDetailState {
  final String message;

  const ItemDetailError({@required this.message});

  @override
  List<Object> get props => [message];
}

class ItemDetailSuccess extends ItemDetailState {
  final Item item;

  const ItemDetailSuccess({@required this.item});

  @override
  List<Object> get props => [item];

  @override
  String toString() => 'ItemDetailSuccess { item: ${item.name} }';
}

class ItemEditInitial extends ItemDetailState {
  final Item item;

  const ItemEditInitial({@required this.item});

  @override
  List<Object> get props => [item];

  @override
  String toString() => 'ItemEditInitial { item: ${item.name} }';
}

class ItemAddInitial extends ItemDetailState {
  final String storageId;

  const ItemAddInitial({@required this.storageId});

  @override
  List<Object> get props => [storageId];

  @override
  String toString() => 'ItemAddInitial { storageId: $storageId }';
}

class ItemAddSuccess extends ItemDetailState {
  final Item item;

  const ItemAddSuccess({@required this.item});

  @override
  List<Object> get props => [item];

  @override
  String toString() => 'ItemAddSuccess { item: ${item.name} }';
}

class ItemDeleteSuccess extends ItemDetailState {
  final Item item;

  const ItemDeleteSuccess({@required this.item});

  @override
  List<Object> get props => [item];

  @override
  String toString() => 'ItemDeleteSuccess { item: ${item.name} }';
}
