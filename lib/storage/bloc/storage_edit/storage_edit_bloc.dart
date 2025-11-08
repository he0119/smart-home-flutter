import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smarthome/storage/model/storage.dart';
import 'package:smarthome/storage/repository/storage_repository.dart';
import 'package:smarthome/utils/exceptions.dart';

part 'storage_edit_event.dart';
part 'storage_edit_state.dart';

class StorageEditBloc extends Bloc<StorageEditEvent, StorageEditState> {
  final StorageRepository storageRepository;

  StorageEditBloc({required this.storageRepository})
    : super(StorageEditInitial()) {
    on<StorageUpdated>(_onStorageUpdated);
    on<StorageAdded>(_onStorageAdded);
    on<StorageDeleted>(_onStorageDeleted);
  }

  FutureOr<void> _onStorageUpdated(
    StorageUpdated event,
    Emitter<StorageEditState> emit,
  ) async {
    emit(StorageEditInProgress());
    try {
      final storage = await storageRepository.updateStorage(
        id: event.id,
        name: event.name,
        parentId: event.parentId,
        description: event.description,
      );
      emit(StorageUpdateSuccess(storage: storage));
    } on MyException catch (e) {
      emit(StorageEditFailure(e.message));
    }
  }

  FutureOr<void> _onStorageAdded(
    StorageAdded event,
    Emitter<StorageEditState> emit,
  ) async {
    emit(StorageEditInProgress());
    try {
      final storage = await storageRepository.addStorage(
        name: event.name,
        parentId: event.parentId,
        description: event.description,
      );
      emit(StorageAddSuccess(storage: storage));
    } on MyException catch (e) {
      emit(StorageEditFailure(e.message));
    }
  }

  FutureOr<void> _onStorageDeleted(
    StorageDeleted event,
    Emitter<StorageEditState> emit,
  ) async {
    emit(StorageEditInProgress());
    try {
      await storageRepository.deleteStorage(storageId: event.storage.id);
      emit(StorageDeleteSuccess(storage: event.storage));
    } on MyException catch (e) {
      emit(StorageEditFailure(e.message));
    }
  }
}
