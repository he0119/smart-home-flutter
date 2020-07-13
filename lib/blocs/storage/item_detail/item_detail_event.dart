part of 'item_detail_bloc.dart';

abstract class ItemDetailEvent {
  const ItemDetailEvent();
}

class ItemDetailChanged extends ItemDetailEvent {
  final String itemId;

  const ItemDetailChanged({@required this.itemId});

  @override
  String toString() => 'ItemChanged { itemId: $itemId }';
}

class ItemDetailRefreshed extends ItemDetailEvent {
  final String itemId;

  const ItemDetailRefreshed({@required this.itemId});

  @override
  String toString() => 'ItemRefreshed { itemId: $itemId }';
}
