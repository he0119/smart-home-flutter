import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:xiao_mi_push_plugin/xiao_mi_push_plugin.dart';

part 'push_event.dart';
part 'push_state.dart';

class PushBloc extends Bloc<PushEvent, PushState> {
  PushBloc() : super(PushInitial());

  @override
  Stream<PushState> mapEventToState(
    PushEvent event,
  ) async* {
    if (event is PushInitial) {
      if (!kIsWeb && Platform.isAndroid) {
        // 注册小米推送
        XiaoMiPushPlugin.init(
            appId: 'XiaoMiPushAppId', appKey: 'XiaoMiPushAppKey');
      }
    }
  }
}
