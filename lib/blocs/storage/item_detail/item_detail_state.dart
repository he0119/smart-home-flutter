part of 'item_detail_bloc.dart';

abstract class ItemDetailState extends Equatable {
  const ItemDetailState();

  @override
  List<Object> get props => [];
}

class ItemDetailInProgress extends ItemDetailState {
  @override
  String toString() => 'ItemDetailInProgress';
}

class ItemDetailFailure extends ItemDetailState {
  final String message;
  final String itemName;
  final String itemId;

  const ItemDetailFailure(
    this.message, {
    @required this.itemName,
    @required this.itemId,
  });

  @override
  List<Object> get props => [message, itemName, itemId];

  @override
  String toString() => 'ItemDetailFailure(message: $message)';
}

class ItemDetailSuccess extends ItemDetailState {
  final Item item;

  const ItemDetailSuccess({@required this.item});

  @override
  List<Object> get props => [item];

  @override
  String toString() => 'ItemDetailSuccess(item: $item)';
}
