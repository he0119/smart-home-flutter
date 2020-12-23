import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

import 'package:smart_home/models/storage.dart';
import 'package:smart_home/repositories/storage_repository.dart';

part 'recycle_bin_event.dart';
part 'recycle_bin_state.dart';

class RecycleBinBloc extends Bloc<RecycleBinEvent, RecycleBinState> {
  final StorageRepository storageRepository;

  RecycleBinBloc({
    @required this.storageRepository,
  }) : super(RecycleBinInitial());

  @override
  Stream<RecycleBinState> mapEventToState(
    RecycleBinEvent event,
  ) async* {
    if (event is RecycleBinFetched) {
      yield RecycleBinInProgress();
      try {
        final List<Item> results = await storageRepository.deletedItems();
        yield RecycleBinSuccess(items: results);
      } catch (e) {
        yield RecycleBinFailure(e.message);
      }
    }
    if (event is RecycleBinRefreshed) {
      try {
        final List<Item> results =
            await storageRepository.deletedItems(cache: false);
        yield RecycleBinSuccess(items: results);
      } catch (e) {
        yield RecycleBinFailure(e.message);
      }
    }
  }
}
