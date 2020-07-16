part of 'item_detail_bloc.dart';

abstract class ItemDetailState {
  const ItemDetailState();
}

class ItemDetailInProgress extends ItemDetailState {
  @override
  String toString() => 'ItemDetailInProgress';
}

class ItemDetailFailure extends ItemDetailState {
  final String message;
  final String itemId;

  const ItemDetailFailure(
    this.message, {
    @required this.itemId,
  });

  @override
  String toString() => 'ItemDetailFailure { message: $message }';
}

class ItemDetailSuccess extends ItemDetailState {
  final Item item;

  const ItemDetailSuccess({@required this.item});

  @override
  String toString() => 'ItemDetailSuccess { item: ${item.name} }';
}
