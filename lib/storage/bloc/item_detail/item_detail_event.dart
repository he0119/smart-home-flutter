part of 'item_detail_bloc.dart';

abstract class ItemDetailEvent extends Equatable {
  const ItemDetailEvent();

  @override
  List<Object?> get props => [];
}

class ItemDetailStarted extends ItemDetailEvent {
  final String id;

  const ItemDetailStarted({
    required this.id,
  });

  @override
  List<Object?> get props => [id];

  @override
  String toString() => 'ItemDetailStarted(id: $id)';
}

class ItemDetailRefreshed extends ItemDetailEvent {
  @override
  String toString() => 'ItemDetailRefreshed';
}
