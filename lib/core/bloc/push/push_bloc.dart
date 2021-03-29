import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:smarthome/core/bloc/blocs.dart';
import 'package:smarthome/core/model/models.dart';
import 'package:smarthome/core/repository/repositories.dart';
import 'package:flutter/services.dart';
import 'package:smarthome/utils/exceptions.dart';

part 'push_event.dart';
part 'push_state.dart';

class PushBloc extends Bloc<PushEvent, PushState> {
  static final Logger _log = Logger('PushBloc');
  final PushRepository pushRepository;
  final AppPreferencesBloc appPreferencesBloc;

  static const miPushMethod = MethodChannel('hehome.xyz/push/method');
  static const miPushEvent = EventChannel('hehome.xyz/push/event');

  PushBloc({
    required this.pushRepository,
    required this.appPreferencesBloc,
  }) : super(PushInProgress());

  @override
  Stream<PushState> mapEventToState(
    PushEvent event,
  ) async* {
    if (event is PushStarted) {
      // 仅在安卓上注册
      if (!kIsWeb && Platform.isAndroid) {
        yield PushInProgress();
        MiPushKey miPushKey;
        final miPushAppId = appPreferencesBloc.state.miPushAppId;
        final miPushAppKey = appPreferencesBloc.state.miPushAppKey;
        if (miPushAppId != null && miPushAppKey != null) {
          miPushKey = MiPushKey(appId: miPushAppId, appKey: miPushAppKey);
        } else {
          miPushKey = await pushRepository.miPushKey();
          appPreferencesBloc.add(MiPushKeyChanged(
            miPushAppId: miPushKey.appId,
            miPushAppKey: miPushKey.appKey,
          ));
        }
        // 注册小米推送
        _log.fine('小米推送注册中');
        await miPushMethod.invokeMethod(
            'init', {'appId': miPushKey.appId, 'appKey': miPushKey.appKey});
        miPushMethod.setMethodCallHandler(
          (call) async {
            if (call.method == 'ReceiveRegisterResult' &&
                call.arguments != null) {
              _log.fine('小米推送注册成功');
              final String regId = call.arguments;
              add(PushUpdated(miPush: MiPush(regId: null)));

              if (regId != appPreferencesBloc.state.miPushRegId) {
                final mipush = await pushRepository.updateMiPush(regId: regId);
                add(PushUpdated(miPush: mipush));
                appPreferencesBloc
                    .add(MiPushRegIdChanged(miPushRegId: mipush.regId!));
                _log.fine('小米推送注册标识符上传成功。');
              }
            }
          },
        );
      }
    }
    if (event is PushUpdated) {
      yield PushSuccess(miPush: event.miPush);
    }
    if (event is PushRefreshed) {
      yield PushInProgress();
      try {
        final mipush = await pushRepository.miPush();
        yield PushSuccess(miPush: mipush);
      } on MyException catch (e) {
        yield PushError(e.message);
      }
    }
  }
}
