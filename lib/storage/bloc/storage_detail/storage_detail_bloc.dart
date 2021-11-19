import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/storage/model/storage.dart';
import 'package:smarthome/storage/repository/storage_repository.dart';
import 'package:smarthome/utils/exceptions.dart';

part 'storage_detail_event.dart';
part 'storage_detail_state.dart';

class StorageDetailBloc extends Bloc<StorageDetailEvent, StorageDetailState> {
  final StorageRepository storageRepository;

  StorageDetailBloc({
    required this.storageRepository,
  }) : super(StorageDetailInProgress()) {
    on<StorageDetailFetched>(_onStorageDetailFetched);
  }

  FutureOr<void> _onStorageDetailFetched(
      StorageDetailFetched event, Emitter<StorageDetailState> emit) async {
    final currentState = state;
    try {
      // 如果需要刷新，则显示加载界面
      // 因为需要请求网络最好提示用户
      if (!event.cache) {
        emit(StorageDetailInProgress());
      }
      if (event.cache &&
          currentState is StorageDetailSuccess &&
          !currentState.hasReachedMax) {
        // 如果不需要刷新，不是首次启动，或遇到错误，并且有下一页
        // 则获取下一页
        final storage = currentState.storage;
        if (storage == null) {
          final results = await storageRepository.rootStorage(
            after: currentState.storagePageInfo.endCursor,
            cache: false,
          );
          emit(StorageDetailSuccess(
            storages: currentState.storages! + results.item1,
            storagePageInfo:
                currentState.storagePageInfo.copyWith(results.item2),
            itemPageInfo: PageInfo(hasNextPage: false),
          ));
        } else {
          final results = await storageRepository.storage(
            id: storage.id,
            itemCursor: currentState.itemPageInfo.endCursor,
            storageCursor: currentState.storagePageInfo.endCursor,
            cache: false,
          );
          emit(StorageDetailSuccess(
            storage: storage.copyWith(
              children: storage.children! + results!.item1.children!,
              items: storage.items! + results.item1.items!,
            ),
            storagePageInfo:
                currentState.storagePageInfo.copyWith(results.item2),
            itemPageInfo: currentState.itemPageInfo.copyWith(results.item3),
          ));
        }
      } else {
        // 其他情况根据设置看是否需要打开缓存，并获取第一页
        if (event.id == '') {
          final results =
              await storageRepository.rootStorage(cache: event.cache);
          emit(StorageDetailSuccess(
            storages: results.item1,
            storagePageInfo: results.item2,
            itemPageInfo: PageInfo(hasNextPage: false),
          ));
        } else {
          final results = await storageRepository.storage(
            id: event.id,
            cache: event.cache,
          );
          if (results == null) {
            emit(StorageDetailFailure(
              '获取位置失败，位置不存在',
              id: event.id,
            ));
            return;
          }
          emit(StorageDetailSuccess(
            storage: results.item1,
            storagePageInfo: results.item2,
            itemPageInfo: results.item3,
          ));
        }
      }
    } on MyException catch (e) {
      emit(StorageDetailFailure(
        e.message,
        id: event.id,
      ));
    }
  }
}
