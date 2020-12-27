part of 'item_detail_bloc.dart';

abstract class ItemDetailEvent extends Equatable {
  const ItemDetailEvent();

  @override
  List<Object> get props => [];
}

class ItemDetailStarted extends ItemDetailEvent {
  final String itemName;
  final String itemId;

  const ItemDetailStarted({
    @required this.itemName,
    this.itemId,
  });

  @override
  List<Object> get props => [itemName, itemId];

  @override
  String toString() => 'ItemDetailChanged(itemName: $itemName)';
}

class ItemDetailRefreshed extends ItemDetailEvent {
  @override
  String toString() => 'ItemDetailRefreshed';
}
