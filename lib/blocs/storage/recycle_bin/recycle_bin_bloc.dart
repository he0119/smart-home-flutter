import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_home/models/models.dart';

import 'package:smart_home/models/storage.dart';
import 'package:smart_home/repositories/storage_repository.dart';

part 'recycle_bin_event.dart';
part 'recycle_bin_state.dart';

class RecycleBinBloc extends Bloc<RecycleBinEvent, RecycleBinState> {
  final StorageRepository storageRepository;

  RecycleBinBloc({
    @required this.storageRepository,
  }) : super(RecycleBinInProgress());

  @override
  Stream<RecycleBinState> mapEventToState(
    RecycleBinEvent event,
  ) async* {
    final currentState = state;
    if (event is RecycleBinFetched && !_hasReachedMax(currentState)) {
      try {
        if (currentState is RecycleBinSuccess && !event.refresh) {
          final results = await storageRepository.deletedItems(
            after: currentState.pageInfo.endCursor,
          );
          yield RecycleBinSuccess(
            items: currentState.items + results.item1,
            pageInfo: currentState.pageInfo.copyWith(results.item2),
          );
        } else {
          final results = await storageRepository.deletedItems(
            cache: !event.refresh,
          );
          yield RecycleBinSuccess(
            items: results.item1,
            pageInfo: results.item2,
          );
        }
      } catch (e) {
        yield RecycleBinFailure(e.message);
      }
    }
  }
}

bool _hasReachedMax(RecycleBinState currentState) {
  if (currentState is RecycleBinSuccess) {
    return currentState.hasReachedMax;
  }
  return false;
}
