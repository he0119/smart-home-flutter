import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:smart_home/repositories/version_repository.dart';
import 'package:version/version.dart';

part 'update_event.dart';
part 'update_state.dart';

class UpdateBloc extends Bloc<UpdateEvent, UpdateState> {
  @override
  UpdateState get initialState => UpdateInitial();

  @override
  Stream<UpdateState> mapEventToState(
    UpdateEvent event,
  ) async* {
    if (event is UpdateStarted) {
      bool needUpdate = await versionRepository.needUpdate();
      if (needUpdate) {
        String url = await versionRepository.updateUrl();
        Version version = await versionRepository.onlineVersion;
        yield UpdateSuccess(needUpdate: needUpdate, url: url, version: version);
      } else {
        yield UpdateSuccess(needUpdate: needUpdate);
      }
    }
  }
}
