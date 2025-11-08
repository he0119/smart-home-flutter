import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:smarthome/core/model/models.dart';
import 'package:smarthome/core/repository/repositories.dart';
import 'package:smarthome/app/settings/settings_controller.dart';
import 'package:smarthome/utils/exceptions.dart';

part 'push_event.dart';
part 'push_state.dart';

class PushBloc extends Bloc<PushEvent, PushState> {
  static final Logger _log = Logger('PushBloc');
  final PushRepository pushRepository;
  final SettingsController settingsController;

  static const miPushMethod = MethodChannel('hehome.xyz/push/method');
  static const miPushEvent = EventChannel('hehome.xyz/push/event');

  PushBloc({required this.pushRepository, required this.settingsController})
    : super(PushInProgress()) {
    on<PushStarted>(_onPushStarted);
    on<PushUpdated>(_onPushUpdated);
    on<PushRefreshed>(_onPushRefreshed);
  }

  FutureOr<void> _onPushStarted(
    PushStarted event,
    Emitter<PushState> emit,
  ) async {
    // 仅在安卓上注册
    if (!kIsWeb && Platform.isAndroid) {
      emit(PushInProgress());
      MiPushKey miPushKey;
      final miPushAppId = settingsController.miPushAppId;
      final miPushAppKey = settingsController.miPushAppKey;
      if (miPushAppId != null && miPushAppKey != null) {
        miPushKey = MiPushKey(appId: miPushAppId, appKey: miPushAppKey);
      } else {
        miPushKey = await pushRepository.miPushKey();
        settingsController.updateMiPushAppId(miPushKey.appId);
        settingsController.updateMiPushAppKey(miPushKey.appKey);
      }
      // 注册小米推送
      _log.fine('小米推送注册中');
      await miPushMethod.invokeMethod('init', {
        'appId': miPushKey.appId,
        'appKey': miPushKey.appKey,
      });
      miPushMethod.setMethodCallHandler((call) async {
        if (call.method == 'ReceiveRegisterResult' && call.arguments != null) {
          _log.fine('小米推送注册成功');
          final String regId = call.arguments;
          add(PushUpdated(regId: regId));
        }
      });
    }
  }

  FutureOr<void> _onPushUpdated(
    PushUpdated event,
    Emitter<PushState> emit,
  ) async {
    emit(PushInProgress());
    try {
      // 获取本地保存的 regId
      final regId = settingsController.miPushRegId;
      // 如果新注册的 regId 与之前的不同，则更新
      if (event.regId != regId) {
        await _updateMiPush(emit, event.regId);
      } else {
        emit(PushSuccess(local: event.regId));
      }
    } on MyException catch (e) {
      emit(PushError(e.message));
    }
  }

  FutureOr<void> _onPushRefreshed(
    PushRefreshed event,
    Emitter<PushState> emit,
  ) async {
    emit(PushInProgress());
    try {
      // 获取服务器上的 regId，如果与本地不同，则更新
      final mipush = await pushRepository.miPush();
      if (event.regId != mipush.regId) {
        await _updateMiPush(emit, event.regId);
      } else {
        emit(PushSuccess(local: event.regId, server: mipush.regId));
      }
    } on MyException catch (e) {
      // 如果服务器上的数据被删除，则还是更新
      if (e.message == '推送未绑定') {
        await _updateMiPush(emit, event.regId);
      } else {
        emit(PushError(e.message));
      }
    }
  }

  FutureOr<void> _updateMiPush(Emitter<PushState> emit, String regId) async {
    final mipush = await pushRepository.updateMiPush(regId: regId);
    _log.fine('小米推送注册标识符上传成功。');
    settingsController.updateMiPushRegId(regId);
    emit(PushSuccess(local: regId, server: mipush.regId!));
  }
}
