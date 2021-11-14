import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:smarthome/core/bloc/blocs.dart';
import 'package:smarthome/core/model/models.dart';
import 'package:smarthome/core/repository/repositories.dart';
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
          'init',
          {'appId': miPushKey.appId, 'appKey': miPushKey.appKey},
        );
        miPushMethod.setMethodCallHandler(
          (call) async {
            if (call.method == 'ReceiveRegisterResult' &&
                call.arguments != null) {
              _log.fine('小米推送注册成功');
              final String regId = call.arguments;
              add(PushUpdated(regId: regId));
            }
          },
        );
      }
    }
    if (event is PushUpdated) {
      yield PushInProgress();
      try {
        // 获取本地保存的 regId
        final regId = appPreferencesBloc.state.miPushRegId;
        // 如果新注册的 regId 与之前的不同，则更新
        if (event.regId != regId) {
          yield* _updateMiPush(event.regId);
        } else {
          yield PushSuccess(local: event.regId);
        }
      } on MyException catch (e) {
        yield PushError(e.message);
      }
    }
    if (event is PushRefreshed) {
      yield PushInProgress();
      try {
        // 获取服务器上的 regId，如果与本地不同，则更新
        final mipush = await pushRepository.miPush();
        if (event.regId != mipush.regId) {
          yield* _updateMiPush(event.regId);
        } else {
          yield PushSuccess(local: event.regId, server: mipush.regId);
        }
      } on MyException catch (e) {
        // 如果服务器上的数据被删除，则还是更新
        if (e.message == '推送未绑定') {
          yield* _updateMiPush(event.regId);
        } else {
          yield PushError(e.message);
        }
      }
    }
  }

  Stream<PushState> _updateMiPush(String regId) async* {
    final mipush = await pushRepository.updateMiPush(regId: regId);
    _log.fine('小米推送注册标识符上传成功。');
    appPreferencesBloc.add(MiPushRegIdChanged(miPushRegId: mipush.regId!));
    yield PushSuccess(local: regId, server: mipush.regId!);
  }
}
