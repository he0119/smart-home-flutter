import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_home/models/models.dart';

import 'package:smart_home/models/storage.dart';
import 'package:smart_home/repositories/storage_repository.dart';

part 'consumables_event.dart';
part 'consumables_state.dart';

class ConsumablesBloc extends Bloc<ConsumablesEvent, ConsumablesState> {
  final StorageRepository storageRepository;

  ConsumablesBloc({
    @required this.storageRepository,
  }) : super(ConsumablesInProgress());

  @override
  Stream<ConsumablesState> mapEventToState(
    ConsumablesEvent event,
  ) async* {
    final currentState = state;
    if (event is ConsumablesFetched && !_hasReachedMax(currentState)) {
      try {
        if (currentState is ConsumablesSuccess && !event.refresh) {
          final results = await storageRepository.consumables(
            after: currentState.pageInfo.endCursor,
          );
          yield ConsumablesSuccess(
            items: currentState.items + results.item1,
            pageInfo: currentState.pageInfo.copyWith(results.item2),
          );
        } else {
          final results = await storageRepository.consumables(
            cache: !event.refresh,
          );
          yield ConsumablesSuccess(
            items: results.item1,
            pageInfo: results.item2,
          );
        }
      } catch (e) {
        yield ConsumablesFailure(e.message);
      }
    }
  }
}

bool _hasReachedMax(ConsumablesState currentState) {
  if (currentState is ConsumablesSuccess) {
    return currentState.hasReachedMax;
  }
  return false;
}
