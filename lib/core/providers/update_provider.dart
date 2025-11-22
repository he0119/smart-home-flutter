import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/utils/exceptions.dart';
import 'package:version/version.dart';

part 'update_provider.g.dart';

/// Update state
class UpdateInfo {
  final bool needUpdate;
  final String? url;
  final Version? version;
  final String? errorMessage;
  final String? changelog;

  const UpdateInfo({
    this.needUpdate = false,
    this.url,
    this.version,
    this.errorMessage,
    this.changelog,
  });

  UpdateInfo copyWith({
    bool? needUpdate,
    String? Function()? url,
    Version? Function()? version,
    String? Function()? errorMessage,
    String? Function()? changelog,
  }) {
    return UpdateInfo(
      needUpdate: needUpdate ?? this.needUpdate,
      url: url != null ? url() : this.url,
      version: version != null ? version() : this.version,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      changelog: changelog != null ? changelog() : this.changelog,
    );
  }

  @override
  String toString() {
    return 'UpdateInfo(needUpdate: $needUpdate, url: $url, version: $version, errorMessage: $errorMessage)';
  }
}

/// Update Notifier
@Riverpod(keepAlive: true)
class Update extends _$Update {
  @visibleForTesting
  static bool? debugIsAndroid;

  bool get _isAndroid => debugIsAndroid ?? (!kIsWeb && Platform.isAndroid);

  @override
  UpdateInfo build() {
    return const UpdateInfo();
  }

  Future<void> checkUpdate() async {
    // 暂时只支持 Android
    if (_isAndroid) {
      try {
        final versionRepository = ref.read(versionRepositoryProvider);
        final needUpdate = await versionRepository.needUpdate();

        if (needUpdate) {
          final url = await versionRepository.updateUrl();
          final version = await versionRepository.onlineVersion;
          final changelog = versionRepository.changelog;
          state = UpdateInfo(
            needUpdate: needUpdate,
            url: url,
            version: version,
            changelog: changelog,
          );
        } else {
          state = UpdateInfo(needUpdate: needUpdate);
        }
      } on MyException catch (e) {
        state = UpdateInfo(errorMessage: e.message);
      }
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: () => null);
  }
}
