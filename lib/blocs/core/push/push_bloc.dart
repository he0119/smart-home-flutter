import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:smart_home/blocs/core/blocs.dart';
import 'package:smart_home/models/push.dart';
import 'package:smart_home/repositories/push_repository.dart';
import 'package:xiao_mi_push_plugin/xiao_mi_push_plugin.dart';
import 'package:xiao_mi_push_plugin/xiao_mi_push_plugin_listener.dart';

part 'push_event.dart';
part 'push_state.dart';

class PushBloc extends Bloc<PushEvent, PushState> {
  static final Logger _log = Logger('PushBloc');
  final PushRepository pushRepository;
  final AppPreferencesBloc appPreferencesBloc;

  PushBloc({
    @required this.pushRepository,
    @required this.appPreferencesBloc,
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
        if (appPreferencesBloc.state.miPushAppId == null) {
          miPushKey = await pushRepository.miPushKey();
          appPreferencesBloc.add(MiPushKeyChanged(
            miPushAppId: miPushKey.appId,
            miPushAppKey: miPushKey.appKey,
          ));
        } else {
          miPushKey = MiPushKey(
              appId: appPreferencesBloc.state.miPushAppId,
              appKey: appPreferencesBloc.state.miPushAppKey);
        }
        // 注册小米推送
        XiaoMiPushPlugin.init(appId: miPushKey.appId, appKey: miPushKey.appKey);
        XiaoMiPushPlugin.addListener((type, data) async {
          if (type == XiaoMiPushListenerTypeEnum.ReceiveRegisterResult) {
            _log.fine('小米推送注册成功');
            add(PushUpdated(miPush: MiPush(regId: null)));

            if (data.commandArguments.single !=
                appPreferencesBloc.state.miPushRegId) {
              MiPush mipush = await pushRepository.updateMiPush(
                  regId: data.commandArguments.single);
              add(PushUpdated(miPush: mipush));
              appPreferencesBloc
                  .add(MiPushRegIdChanged(miPushRegId: mipush.regId));
              _log.fine('小米推送注册标识符上传成功。');
            }
          }
        });
      }
    }
    if (event is PushUpdated) {
      yield PushSuccess(miPush: event.miPush);
    }
    if (event is PushRefreshed) {
      yield PushInProgress();
      try {
        MiPush mipush = await pushRepository.miPush();
        yield PushSuccess(miPush: mipush);
      } catch (e) {
        yield PushError(e.message);
      }
    }
  }
}
