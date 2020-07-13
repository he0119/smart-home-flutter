part of 'item_detail_bloc.dart';

abstract class ItemDetailState {
  const ItemDetailState();
}

class ItemDetailInProgress extends ItemDetailState {
  @override
  String toString() => 'ItemDetailInProgress';
}

class ItemDetailError extends ItemDetailState {
  final String message;

  const ItemDetailError({@required this.message});
}

class ItemDetailSuccess extends ItemDetailState {
  final Item item;

  const ItemDetailSuccess({@required this.item});

  @override
  String toString() => 'ItemDetailSuccess { item: ${item.name} }';
}
