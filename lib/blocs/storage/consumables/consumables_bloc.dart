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
    if (event is ConsumablesFetched) {
      try {
        if (event.cache &&
            currentState is ConsumablesSuccess &&
            !currentState.hasReachedMax) {
          // 如果不需要刷新，不是首次启动，或遇到错误，并且有下一页
          // 则获取下一页
          final results = await storageRepository.consumables(
            after: currentState.pageInfo.endCursor,
          );
          yield ConsumablesSuccess(
            items: currentState.items + results.item1,
            pageInfo: currentState.pageInfo.copyWith(results.item2),
          );
        } else {
          // 其他情况根据设置看是否需要打开缓存，并获取第一页s
          final results = await storageRepository.consumables(
            cache: event.cache,
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
