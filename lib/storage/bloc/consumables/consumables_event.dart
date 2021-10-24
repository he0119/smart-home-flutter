part of 'consumables_bloc.dart';

abstract class ConsumablesEvent extends Equatable {
  const ConsumablesEvent();
}

class ConsumablesFetched extends ConsumablesEvent {
  final bool cache;

  const ConsumablesFetched({
    this.cache = true,
  });

  @override
  List<Object> get props => [cache];

  @override
  String toString() => 'ConsumablesFetched(cache: $cache)';
}
