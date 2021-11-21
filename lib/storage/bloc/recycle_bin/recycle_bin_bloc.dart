import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/storage/model/storage.dart';
import 'package:smarthome/storage/repository/storage_repository.dart';
import 'package:smarthome/utils/exceptions.dart';

part 'recycle_bin_event.dart';
part 'recycle_bin_state.dart';

class RecycleBinBloc extends Bloc<RecycleBinEvent, RecycleBinState> {
  final StorageRepository storageRepository;

  RecycleBinBloc({
    required this.storageRepository,
  }) : super(RecycleBinInProgress()) {
    on<RecycleBinFetched>(_onRecycleBinFetched);
  }

  FutureOr<void> _onRecycleBinFetched(
      RecycleBinFetched event, Emitter<RecycleBinState> emit) async {
    final currentState = state;
    try {
      // 如果需要刷新，则显示加载界面
      // 因为需要请求网络最好提示用户
      if (!event.cache) {
        emit(RecycleBinInProgress());
      }
      if (event.cache &&
          currentState is RecycleBinSuccess &&
          !currentState.hasReachedMax) {
        // 如果不需要刷新，不是首次启动，或遇到错误，并且有下一页
        // 则获取下一页
        final results = await storageRepository.deletedItems(
          after: currentState.pageInfo.endCursor,
          cache: false,
        );
        emit(RecycleBinSuccess(
          items: currentState.items + results.item1,
          pageInfo: currentState.pageInfo.copyWith(results.item2),
        ));
      } else {
        // 其他情况根据设置看是否需要打开缓存，并获取第一页
        final results = await storageRepository.deletedItems(
          cache: event.cache,
        );
        emit(RecycleBinSuccess(
          items: results.item1,
          pageInfo: results.item2,
        ));
      }
    } on MyException catch (e) {
      emit(RecycleBinFailure(e.message));
    }
  }
}
