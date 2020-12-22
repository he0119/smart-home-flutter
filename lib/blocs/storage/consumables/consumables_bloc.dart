import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

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
    if (event is ConsumablesFetched) {
      yield ConsumablesInProgress();
      try {
        final List<Item> results = await storageRepository.consumables();
        yield ConsumablesSuccess(items: results);
      } catch (e) {
        yield ConsumablesFailure(e.message);
      }
    }
    if (event is ConsumablesRefreshed) {
      try {
        final List<Item> results =
            await storageRepository.consumables(cache: false);
        yield ConsumablesSuccess(items: results);
      } catch (e) {
        yield ConsumablesFailure(e.message);
      }
    }
  }
}
