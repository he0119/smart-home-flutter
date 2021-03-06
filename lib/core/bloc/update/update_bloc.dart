import 'dart:io' show Platform;

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:smarthome/core/repository/repositories.dart';
import 'package:smarthome/utils/exceptions.dart';
import 'package:version/version.dart';

part 'update_event.dart';
part 'update_state.dart';

class UpdateBloc extends Bloc<UpdateEvent, UpdateState> {
  VersionRepository versionRepository;

  UpdateBloc({required this.versionRepository}) : super(UpdateInitial());

  @override
  Stream<UpdateState> mapEventToState(UpdateEvent event) async* {
    // 暂时只支持 Android
    if (event is UpdateStarted && !kIsWeb && Platform.isAndroid) {
      try {
        final needUpdate = await versionRepository.needUpdate();
        if (needUpdate) {
          final url = await versionRepository.updateUrl();
          final version = await versionRepository.onlineVersion;
          yield UpdateSuccess(
              needUpdate: needUpdate, url: url, version: version);
        } else {
          yield UpdateSuccess(needUpdate: needUpdate);
        }
      } on MyException catch (e) {
        yield UpdateFailure(e.message);
      }
    }
  }
}
