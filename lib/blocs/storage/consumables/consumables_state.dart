part of 'consumables_bloc.dart';

abstract class ConsumablesState extends Equatable {
  const ConsumablesState();

  @override
  List<Object> get props => [];
}

class ConsumablesInProgress extends ConsumablesState {
  @override
  String toString() => 'ConsumablesInProgress';
}

class ConsumablesFailure extends ConsumablesState {
  final String message;

  const ConsumablesFailure(this.message);

  @override
  List<Object> get props => [message];

  @override
  String toString() => 'ConsumablesFailure(message: $message)';
}

class ConsumablesSuccess extends ConsumablesState {
  final List<Item> items;
  final PageInfo pageInfo;

  const ConsumablesSuccess({
    @required this.items,
    this.pageInfo,
  });

  bool get hasReachedMax => !pageInfo.hasNextPage;

  @override
  List<Object> get props => [items, pageInfo];

  @override
  String toString() =>
      'ConsumablesSuccess(items: ${items.length}, hasReachedMax: $hasReachedMax)';
}
