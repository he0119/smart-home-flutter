part of 'item_detail_bloc.dart';

abstract class ItemDetailEvent extends Equatable {
  const ItemDetailEvent();

  @override
  List<Object?> get props => [];
}

class ItemDetailStarted extends ItemDetailEvent {
  final String name;
  final String? id;

  const ItemDetailStarted({
    required this.name,
    this.id,
  });

  @override
  List<Object?> get props => [name, id];

  @override
  String toString() => 'ItemDetailStarted(name: $name, id: $id)';
}

class ItemDetailRefreshed extends ItemDetailEvent {
  @override
  String toString() => 'ItemDetailRefreshed';
}
