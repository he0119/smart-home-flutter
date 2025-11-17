import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/storage/model/storage.dart';
import 'package:smarthome/utils/exceptions.dart';

/// Storage edit state
class StorageEditState {
  final StorageEditStatus status;
  final String errorMessage;
  final Storage? storage;

  const StorageEditState({
    this.status = StorageEditStatus.initial,
    this.errorMessage = '',
    this.storage,
  });

  StorageEditState copyWith({
    StorageEditStatus? status,
    String? errorMessage,
    Storage? storage,
  }) {
    return StorageEditState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      storage: storage ?? this.storage,
    );
  }
}

enum StorageEditStatus {
  initial,
  loading,
  addSuccess,
  updateSuccess,
  deleteSuccess,
  failure,
}

/// Storage edit notifier
class StorageEditNotifier extends Notifier<StorageEditState> {
  @override
  StorageEditState build() {
    return const StorageEditState();
  }

  Future<void> addStorage({
    required String name,
    String? parentId,
    String? description,
  }) async {
    state = state.copyWith(status: StorageEditStatus.loading);

    try {
      final storageRepository = ref.read(storageRepositoryProvider);
      final storage = await storageRepository.addStorage(
        name: name,
        parentId: parentId,
        description: description,
      );
      state = state.copyWith(
        status: StorageEditStatus.addSuccess,
        storage: storage,
      );
    } on MyException catch (e) {
      state = state.copyWith(
        status: StorageEditStatus.failure,
        errorMessage: e.message,
      );
    }
  }

  Future<void> updateStorage({
    required String id,
    required String name,
    String? parentId,
    String? description,
  }) async {
    state = state.copyWith(status: StorageEditStatus.loading);

    try {
      final storageRepository = ref.read(storageRepositoryProvider);
      final storage = await storageRepository.updateStorage(
        id: id,
        name: name,
        parentId: parentId,
        description: description,
      );
      state = state.copyWith(
        status: StorageEditStatus.updateSuccess,
        storage: storage,
      );
    } on MyException catch (e) {
      state = state.copyWith(
        status: StorageEditStatus.failure,
        errorMessage: e.message,
      );
    }
  }

  Future<void> deleteStorage(Storage storage) async {
    state = state.copyWith(status: StorageEditStatus.loading);

    try {
      final storageRepository = ref.read(storageRepositoryProvider);
      await storageRepository.deleteStorage(storageId: storage.id);
      state = state.copyWith(
        status: StorageEditStatus.deleteSuccess,
        storage: storage,
      );
    } on MyException catch (e) {
      state = state.copyWith(
        status: StorageEditStatus.failure,
        errorMessage: e.message,
      );
    }
  }

  void reset() {
    state = const StorageEditState();
  }
}

/// Storage edit provider
final storageEditProvider =
    NotifierProvider<StorageEditNotifier, StorageEditState>(
      StorageEditNotifier.new,
    );
