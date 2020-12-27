part of 'consumables_bloc.dart';

abstract class ConsumablesEvent extends Equatable {
  const ConsumablesEvent();
}

class ConsumablesFetched extends ConsumablesEvent {
  final bool refresh;

  ConsumablesFetched({
    this.refresh = false,
  });

  @override
  List<Object> get props => [refresh];

  @override
  String toString() => 'ConsumablesFetched(refresh: $refresh)';
}
