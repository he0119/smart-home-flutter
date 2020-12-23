part of 'consumables_bloc.dart';

abstract class ConsumablesState {
  const ConsumablesState();
}

class ConsumablesInProgress extends ConsumablesState {
  @override
  String toString() => 'ConsumablesInProgress';
}

class ConsumablesFailure extends ConsumablesState {
  final String message;

  const ConsumablesFailure(this.message);

  @override
  String toString() => 'ConsumablesFailure { message: $message }';
}

class ConsumablesSuccess extends ConsumablesState {
  final List<Item> items;

  const ConsumablesSuccess({@required this.items});

  @override
  String toString() => 'ConsumablesSuccess { items: ${items.length} }';
}
