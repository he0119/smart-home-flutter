import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/storage/model/storage.dart';
import 'package:smarthome/utils/constants.dart';
import 'package:smarthome/utils/exceptions.dart';

/// Storage detail status
enum StorageDetailStatus { initial, loading, success, failure }

/// Storage detail state
class StorageDetailState {
  final StorageDetailStatus status;
  final String errorMessage;
  final Storage storage;
  final PageInfo itemPageInfo;
  final PageInfo storagePageInfo;

  const StorageDetailState({
    this.status = StorageDetailStatus.initial,
    this.errorMessage = '',
    this.storage = const Storage(id: '', name: ''),
    this.storagePageInfo = const PageInfo(hasNextPage: false),
    this.itemPageInfo = const PageInfo(hasNextPage: false),
  });

  bool get hasReachedMax =>
      !itemPageInfo.hasNextPage && !storagePageInfo.hasNextPage;

  StorageDetailState copyWith({
    StorageDetailStatus? status,
    String? errorMessage,
    Storage? storage,
    PageInfo? itemPageInfo,
    PageInfo? storagePageInfo,
  }) {
    return StorageDetailState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      storage: storage ?? this.storage,
      itemPageInfo: itemPageInfo ?? this.itemPageInfo,
      storagePageInfo: storagePageInfo ?? this.storagePageInfo,
    );
  }

  @override
  String toString() {
    return 'StorageDetailState(status: $status, storage: $storage, itemPageInfo: $itemPageInfo, storagePageInfo: $storagePageInfo)';
  }
}

/// Storage detail notifier
class StorageDetailNotifier extends Notifier<StorageDetailState> {
  late String _storageId;

  @override
  StorageDetailState build() {
    return const StorageDetailState();
  }

  /// Initialize with storage ID and load data
  void initialize(String storageId) {
    _storageId = storageId;
    _loadStorage(cache: true);
  }

  /// Refresh storage data
  void refresh() {
    _loadStorage(cache: false);
  }

  /// Fetch more data (pagination)
  Future<void> fetchMore() async {
    if (state.hasReachedMax || state.status == StorageDetailStatus.loading) {
      return;
    }

    try {
      final storageRepository = ref.read(storageRepositoryProvider);
      final storage = state.storage;

      if (_storageId == homeStorage.id) {
        final results = await storageRepository.rootStorage(
          after: state.storagePageInfo.endCursor,
          cache: false,
        );
        state = state.copyWith(
          storage: storage.copyWith(
            name: homeStorage.name,
            children: storage.children! + results.item1,
            items: [],
          ),
          storagePageInfo: results.item2,
        );
      } else {
        final results = await storageRepository.storage(
          id: storage.id,
          itemCursor: state.itemPageInfo.endCursor,
          storageCursor: state.storagePageInfo.endCursor,
          cache: false,
        );
        if (results != null) {
          state = state.copyWith(
            storage: storage.copyWith(
              children: storage.children! + results.item1.children!,
              items: storage.items! + results.item1.items!,
            ),
            storagePageInfo: state.storagePageInfo.copyWith(results.item2),
            itemPageInfo: state.itemPageInfo.copyWith(results.item3),
          );
        }
      }
    } on MyException catch (e) {
      state = state.copyWith(
        status: StorageDetailStatus.failure,
        errorMessage: e.message,
      );
    }
  }

  Future<void> _loadStorage({required bool cache}) async {
    if (!cache) {
      state = state.copyWith(status: StorageDetailStatus.loading);
    }

    try {
      final storageRepository = ref.read(storageRepositoryProvider);

      if (_storageId == homeStorage.id) {
        final results = await storageRepository.rootStorage(cache: cache);
        state = state.copyWith(
          status: StorageDetailStatus.success,
          storage: Storage(
            id: homeStorage.id,
            name: homeStorage.name,
            children: results.item1,
            items: [],
          ),
          storagePageInfo: results.item2,
        );
      } else {
        final results = await storageRepository.storage(
          id: _storageId,
          cache: cache,
        );
        if (results == null) {
          state = state.copyWith(
            status: StorageDetailStatus.failure,
            errorMessage: '获取位置失败，位置不存在',
          );
          return;
        }
        state = state.copyWith(
          status: StorageDetailStatus.success,
          storage: results.item1,
          storagePageInfo: results.item2,
          itemPageInfo: results.item3,
        );
      }
    } on MyException catch (e) {
      state = state.copyWith(
        status: StorageDetailStatus.failure,
        errorMessage: e.message,
      );
    }
  }
}

/// Storage detail provider
final storageDetailProvider =
    NotifierProvider<StorageDetailNotifier, StorageDetailState>(
      StorageDetailNotifier.new,
    );
