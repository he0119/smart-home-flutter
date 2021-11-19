import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/storage/model/storage.dart';
import 'package:smarthome/storage/repository/storage_repository.dart';
import 'package:smarthome/utils/exceptions.dart';

part 'consumables_event.dart';
part 'consumables_state.dart';

class ConsumablesBloc extends Bloc<ConsumablesEvent, ConsumablesState> {
  final StorageRepository storageRepository;

  ConsumablesBloc({
    required this.storageRepository,
  }) : super(ConsumablesInProgress()) {
    on<ConsumablesFetched>(_onConsumablesFetched);
  }

  FutureOr<void> _onConsumablesFetched(
      ConsumablesFetched event, Emitter<ConsumablesState> emit) async {
    final currentState = state;
    try {
      // 如果需要刷新，则显示加载界面
      // 因为需要请求网络最好提示用户
      if (!event.cache) {
        emit(ConsumablesInProgress());
      }
      if (event.cache &&
          currentState is ConsumablesSuccess &&
          !currentState.hasReachedMax) {
        // 如果不需要刷新，不是首次启动，或遇到错误，并且有下一页
        // 则获取下一页
        final results = await storageRepository.consumables(
          after: currentState.pageInfo!.endCursor,
          cache: false,
        );
        emit(ConsumablesSuccess(
          items: currentState.items + results.item1,
          pageInfo: currentState.pageInfo!.copyWith(results.item2),
        ));
      } else {
        // 其他情况根据设置看是否需要打开缓存，并获取第一页s
        final results = await storageRepository.consumables(
          cache: event.cache,
        );
        emit(ConsumablesSuccess(
          items: results.item1,
          pageInfo: results.item2,
        ));
      }
    } on MyException catch (e) {
      emit(ConsumablesFailure(e.message));
    }
  }
}
