import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:smart_home/blocs/snack_bar/snack_bar_bloc.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/repositories/storage_repository.dart';

part 'storage_detail_event.dart';
part 'storage_detail_state.dart';

class StorageDetailBloc extends Bloc<StorageDetailEvent, StorageDetailState> {
  final StorageRepository storageRepository;
  final SnackBarBloc snackBarBloc;

  StorageDetailBloc({
    @required this.storageRepository,
    @required this.snackBarBloc,
  }) : super(StorageDetailInProgress());

  @override
  Stream<StorageDetailState> mapEventToState(
    StorageDetailEvent event,
  ) async* {
    if (event is StorageDetailRoot) {
      yield StorageDetailInProgress();
      try {
        List<Storage> results = await storageRepository.rootStorage();
        yield StorageDetailRootSuccess(storages: results);
      } catch (e) {
        yield StorageDetailError(message: e.message);
      }
    }
    if (event is StorageDetailRootRefreshed) {
      yield StorageDetailInProgress();
      try {
        List<Storage> results =
            await storageRepository.rootStorage(cache: false);
        yield StorageDetailRootSuccess(storages: results);
      } catch (e) {
        yield StorageDetailError(message: e.message);
      }
    }
    if (event is StorageDetailChanged) {
      yield StorageDetailInProgress();
      try {
        Map<String, dynamic> results =
            await storageRepository.storage(id: event.id);
        yield StorageDetailSuccess(
            storage: results['storage'], ancestors: results['ancestors']);
      } catch (e) {
        yield StorageDetailError(message: e.message);
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
            storage: results['storage'], ancestors: results['ancestors']);
      } catch (e) {
        yield StorageDetailError(message: e.message);
      }
    }
  }
}
