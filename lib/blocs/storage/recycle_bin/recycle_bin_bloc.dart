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
    if (event is RecycleBinFetched) {
      try {
        if (event.cache &&
            currentState is RecycleBinSuccess &&
            !currentState.hasReachedMax) {
          // 如果不需要刷新，不是首次启动，或遇到错误，并且有下一页
          // 则获取下一页
          final results = await storageRepository.deletedItems(
            after: currentState.pageInfo.endCursor,
          );
          yield RecycleBinSuccess(
            items: currentState.items + results.item1,
            pageInfo: currentState.pageInfo.copyWith(results.item2),
          );
        } else {
          // 其他情况根据设置看是否需要打开缓存，并获取第一页
          final results = await storageRepository.deletedItems(
            cache: event.cache,
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
