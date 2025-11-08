part of 'recycle_bin_bloc.dart';

abstract class RecycleBinState extends Equatable {
  const RecycleBinState();

  @override
  List<Object?> get props => [];
}

class RecycleBinInitial extends RecycleBinState {
  @override
  String toString() => 'RecycleBinInitial';
}

class RecycleBinInProgress extends RecycleBinState {
  @override
  String toString() => 'RecycleBinInProgress';
}

class RecycleBinFailure extends RecycleBinState {
  final String message;

  const RecycleBinFailure(this.message);

  @override
  List<Object> get props => [message];

  @override
  String toString() => 'RecycleBinFailure(message: $message)';
}

class RecycleBinSuccess extends RecycleBinState {
  final List<Item> items;
  final PageInfo pageInfo;

  const RecycleBinSuccess({required this.items, required this.pageInfo});

  bool get hasReachedMax => !pageInfo.hasNextPage;

  @override
  List<Object> get props => [items, pageInfo];

  @override
  String toString() =>
      'RecycleBinSuccess'
      '(items: ${items.length}, hasReachedMax: $hasReachedMax)';
}
