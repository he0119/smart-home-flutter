part of 'consumables_bloc.dart';

abstract class ConsumablesEvent {
  const ConsumablesEvent();
}

class ConsumablesRefreshed extends ConsumablesEvent {
  @override
  String toString() => 'ConsumablesRefreshed';
}

class ConsumablesFetched extends ConsumablesEvent {
  @override
  String toString() => 'ConsumablesFetched';
}
