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
  final String name;
  final String? id;

  const ItemDetailFailure(
    this.message, {
    required this.name,
    this.id,
  });

  @override
  List<Object> get props => [message, name];

  @override
  String toString() => 'ItemDetailFailure(message: $message)';
}

class ItemDetailSuccess extends ItemDetailState {
  final Item item;

  const ItemDetailSuccess({required this.item});

  @override
  List<Object> get props => [item];

  @override
  String toString() => 'ItemDetailSuccess(item: $item)';
}
