part of 'recycle_bin_bloc.dart';

abstract class RecycleBinState {
  const RecycleBinState();
}

class RecycleBinInitial extends RecycleBinState {}

class RecycleBinInProgress extends RecycleBinState {
  @override
  String toString() => 'RecycleBinInProgress';
}

class RecycleBinFailure extends RecycleBinState {
  final String message;

  const RecycleBinFailure(this.message);

  @override
  String toString() => 'RecycleBinFailure { message: $message }';
}

class RecycleBinSuccess extends RecycleBinState {
  final List<Item> items;

  const RecycleBinSuccess({@required this.items});

  @override
  String toString() => 'RecycleBinSuccess { items: ${items.length} }';
}
