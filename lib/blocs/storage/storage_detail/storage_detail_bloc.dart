import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:smart_home/blocs/snack_bar/snack_bar_bloc.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/repositories/storage_repository.dart';

part 'storage_detail_event.dart';
part 'storage_detail_state.dart';

class StorageDetailBloc extends Bloc<StorageDetailEvent, StorageDetailState> {
  final StorageRepository storageRepository;
  final SnackBarBloc snackBarBloc;
  bool backImmediately;

  StorageDetailBloc({
    @required this.storageRepository,
    @required this.snackBarBloc,
  }) : super(StorageDetailInProgress());

  @override
  Stream<StorageDetailState> mapEventToState(
    StorageDetailEvent event,
  ) async* {
    if (event is StorageDetailRoot) {
      backImmediately = false;
      yield StorageDetailInProgress();
      try {
        List<Storage> results = await storageRepository.rootStorage();
        yield StorageDetailRootSuccess(storages: results);
      } catch (e) {
        yield StorageDetailFailure(
          message: e.message,
          storageId: null,
        );
      }
    }
    if (event is StorageDetailRootRefreshed) {
      backImmediately = false;
      yield StorageDetailInProgress();
      try {
        List<Storage> results =
            await storageRepository.rootStorage(cache: false);
        yield StorageDetailRootSuccess(storages: results);
      } catch (e) {
        yield StorageDetailFailure(
          message: e.message,
          storageId: null,
        );
      }
    }
    if (event is StorageDetailChanged) {
      // 是否马上返回上级界面
      if (backImmediately == null) {
        backImmediately = true;
      } else {
        backImmediately = false;
      }
      yield StorageDetailInProgress();
      try {
        Map<String, dynamic> results =
            await storageRepository.storage(id: event.id);
        yield StorageDetailSuccess(
          storage: results['storage'],
          ancestors: results['ancestors'],
          backImmediately: backImmediately,
        );
      } catch (e) {
        yield StorageDetailFailure(
          message: e.message,
          storageId: event.id,
        );
      }
    }
    if (event is StorageDetailRefreshed) {
      yield StorageDetailInProgress();
      try {
        Map<String, dynamic> results = await storageRepository.storage(
          id: event.id,
          cache: false,
        );
        yield StorageDetailSuccess(
          storage: results['storage'],
          ancestors: results['ancestors'],
          backImmediately: backImmediately,
        );
      } catch (e) {
        yield StorageDetailFailure(
          message: e.message,
          storageId: event.id,
        );
      }
    }
  }
}
