part of 'item_detail_bloc.dart';

class ItemDetailState extends Equatable {
  /// 当前状态
  final ItemDetailStatus status;

  /// 错误信息
  final String error;

  final Item item;

  const ItemDetailState({
    this.status = ItemDetailStatus.initial,
    this.error = '',
    this.item = const Item(id: '', name: ''),
  });

  @override
  List<Object> get props => [status, error, item];

  @override
  bool get stringify => true;

  ItemDetailState copyWith({
    ItemDetailStatus? status,
    String? error,
    Item? item,
  }) {
    return ItemDetailState(
      status: status ?? this.status,
      error: error ?? this.error,
      item: item ?? this.item,
    );
  }
}
