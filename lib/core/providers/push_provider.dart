import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:smarthome/core/model/models.dart';
import 'package:smarthome/core/providers/repository_providers.dart';
import 'package:smarthome/core/providers/settings_provider.dart';
import 'package:smarthome/utils/exceptions.dart';

/// Push state
class PushInfo {
  final bool isLoading;
  final String? localRegId;
  final String? serverRegId;
  final String? errorMessage;

  const PushInfo({
    this.isLoading = false,
    this.localRegId,
    this.serverRegId,
    this.errorMessage,
  });

  PushInfo copyWith({
    bool? isLoading,
    String? Function()? localRegId,
    String? Function()? serverRegId,
    String? Function()? errorMessage,
  }) {
    return PushInfo(
      isLoading: isLoading ?? this.isLoading,
      localRegId: localRegId != null ? localRegId() : this.localRegId,
      serverRegId: serverRegId != null ? serverRegId() : this.serverRegId,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}

/// Push Notifier
class PushNotifier extends Notifier<PushInfo> {
  static final Logger _log = Logger('PushProvider');

  static const miPushMethod = MethodChannel('hehome.xyz/push/method');
  static const miPushEvent = EventChannel('hehome.xyz/push/event');

  @override
  PushInfo build() {
    return const PushInfo();
  }

  Future<void> startPush() async {
    // 仅在安卓上注册
    if (!kIsWeb && Platform.isAndroid) {
      state = state.copyWith(isLoading: true);

      final settingsNotifier = ref.read(settingsProvider.notifier);
      final settings = ref.read(settingsProvider);
      final pushRepository = ref.read(pushRepositoryProvider);

      MiPushKey miPushKey;
      final miPushAppId = settings.miPushAppId;
      final miPushAppKey = settings.miPushAppKey;

      if (miPushAppId != null && miPushAppKey != null) {
        miPushKey = MiPushKey(appId: miPushAppId, appKey: miPushAppKey);
      } else {
        miPushKey = await pushRepository.miPushKey();
        await settingsNotifier.updateMiPushAppId(miPushKey.appId);
        await settingsNotifier.updateMiPushAppKey(miPushKey.appKey);
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
          await updatePush(regId);
        }
      });
    }
  }

  Future<void> updatePush(String regId) async {
    state = state.copyWith(isLoading: true);

    try {
      final settings = ref.read(settingsProvider);
      final localRegId = settings.miPushRegId;

      // 如果新注册的 regId 与之前的不同，则更新
      if (regId != localRegId) {
        await _updateMiPush(regId);
      } else {
        state = state.copyWith(isLoading: false, localRegId: () => regId);
      }
    } on MyException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: () => e.message);
    }
  }

  Future<void> refreshPush(String regId) async {
    state = state.copyWith(isLoading: true);

    try {
      final pushRepository = ref.read(pushRepositoryProvider);

      // 获取服务器上的 regId，如果与本地不同，则更新
      final mipush = await pushRepository.miPush();
      if (regId != mipush.regId) {
        await _updateMiPush(regId);
      } else {
        state = state.copyWith(
          isLoading: false,
          localRegId: () => regId,
          serverRegId: () => mipush.regId,
        );
      }
    } on MyException catch (e) {
      // 如果服务器上的数据被删除，则还是更新
      if (e.message == '推送未绑定') {
        await _updateMiPush(regId);
      } else {
        state = state.copyWith(isLoading: false, errorMessage: () => e.message);
      }
    }
  }

  Future<void> _updateMiPush(String regId) async {
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final pushRepository = ref.read(pushRepositoryProvider);

    final mipush = await pushRepository.updateMiPush(regId: regId);
    _log.fine('小米推送注册标识符上传成功。');
    await settingsNotifier.updateMiPushRegId(regId);

    state = state.copyWith(
      isLoading: false,
      localRegId: () => regId,
      serverRegId: () => mipush.regId,
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: () => null);
  }
}

/// Push provider
final pushProvider = NotifierProvider<PushNotifier, PushInfo>(PushNotifier.new);
