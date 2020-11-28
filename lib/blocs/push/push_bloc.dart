import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:smart_home/models/push.dart';
import 'package:smart_home/repositories/push_repository.dart';
import 'package:xiao_mi_push_plugin/xiao_mi_push_plugin.dart';
import 'package:xiao_mi_push_plugin/xiao_mi_push_plugin_listener.dart';

part 'push_event.dart';
part 'push_state.dart';

class PushBloc extends Bloc<PushEvent, PushState> {
  static final Logger _log = Logger('PushBloc');
  final PushRepository pushRepository;

  PushBloc({@required this.pushRepository}) : super(PushInitial());

  @override
  Stream<PushState> mapEventToState(
    PushEvent event,
  ) async* {
    if (event is PushStarted) {
      if (!kIsWeb && Platform.isAndroid) {
        yield PushInProgress();
        MiPushKey miPushKey = await pushRepository.miPushKey();
        // 注册小米推送
        XiaoMiPushPlugin.init(appId: miPushKey.appId, appKey: miPushKey.appKey);
        XiaoMiPushPlugin.addListener((type, data) async {
          if (type == XiaoMiPushListenerTypeEnum.ReceiveRegisterResult) {
            await pushRepository.updateMiPush(
                regId: data.commandArguments.single);
            _log.fine('小米推送注册成功');
            add(PushUpdated());
          }
        });
      }
    }
    if (event is PushUpdated) {
      yield PushSuccess();
    }
  }
}
