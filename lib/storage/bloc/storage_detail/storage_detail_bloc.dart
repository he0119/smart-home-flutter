import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/storage/model/storage.dart';
import 'package:smarthome/storage/repository/storage_repository.dart';
import 'package:smarthome/utils/constants.dart';
import 'package:smarthome/utils/exceptions.dart';

part 'storage_detail_event.dart';
part 'storage_detail_state.dart';

enum StorageDetailStatus { initial, loading, success, failure }

class StorageDetailBloc extends Bloc<StorageDetailEvent, StorageDetailState> {
  final StorageRepository storageRepository;

  StorageDetailBloc({required this.storageRepository})
    : super(const StorageDetailState()) {
    on<StorageDetailFetched>(_onStorageDetailFetched);
  }

  FutureOr<void> _onStorageDetailFetched(
    StorageDetailFetched event,
    Emitter<StorageDetailState> emit,
  ) async {
    try {
      // 如果需要刷新，则显示加载界面
      // 因为需要请求网络最好提示用户
      if (!event.cache) {
        emit(state.copyWith(status: StorageDetailStatus.loading));
      }
      if (event.cache &&
          state.status == StorageDetailStatus.success &&
          !state.hasReachedMax) {
        // 如果不需要刷新，不是首次启动，或遇到错误，并且有下一页
        // 则获取下一页
        final storage = state.storage;
        if (storage.id == homeStorage.id) {
          final results = await storageRepository.rootStorage(
            after: state.storagePageInfo.endCursor,
            cache: false,
          );
          emit(
            state.copyWith(
              storage: state.storage.copyWith(
                name: homeStorage.name,
                children: state.storage.children! + results.item1,
                items: [],
              ),
              storagePageInfo: results.item2,
            ),
          );
        } else {
          final results = await storageRepository.storage(
            id: storage.id,
            itemCursor: state.itemPageInfo.endCursor,
            storageCursor: state.storagePageInfo.endCursor,
            cache: false,
          );
          emit(
            state.copyWith(
              storage: storage.copyWith(
                children: storage.children! + results!.item1.children!,
                items: storage.items! + results.item1.items!,
              ),
              storagePageInfo: state.storagePageInfo.copyWith(results.item2),
              itemPageInfo: state.itemPageInfo.copyWith(results.item3),
            ),
          );
        }
      } else {
        // 其他情况根据设置看是否需要打开缓存，并获取第一页
        if (event.id == homeStorage.id) {
          final results = await storageRepository.rootStorage(
            cache: event.cache,
          );
          emit(
            state.copyWith(
              status: StorageDetailStatus.success,
              storage: state.storage.copyWith(
                name: homeStorage.name,
                children: results.item1,
                items: [],
              ),
              storagePageInfo: results.item2,
            ),
          );
        } else {
          final results = await storageRepository.storage(
            id: event.id,
            cache: event.cache,
          );
          if (results == null) {
            emit(
              state.copyWith(
                status: StorageDetailStatus.failure,
                error: '获取位置失败，位置不存在',
              ),
            );
            return;
          }
          emit(
            state.copyWith(
              status: StorageDetailStatus.success,
              storage: results.item1,
              storagePageInfo: results.item2,
              itemPageInfo: results.item3,
            ),
          );
        }
      }
    } on MyException catch (e) {
      emit(
        state.copyWith(status: StorageDetailStatus.failure, error: e.message),
      );
    }
  }
}
