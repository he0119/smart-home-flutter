import 'dart:async';

import 'package:logging/logging.dart';
import 'package:smarthome/bootstrap.dart';
import 'package:smarthome/core/model/app_config.dart';

Future<void> main() async {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    // FIXME: 重新用回 print，因为 dart:developer 的 log 不会在网页版显示
    // https://github.com/flutter/flutter/issues/47913
    // ignore: avoid_print
    print('[${record.level.name}] ${record.loggerName}'
        ' -- ${record.time} -- ${record.message}');
  });

  // 应用的默认配置
  final appConfig = AppConfig(
    appName: '智慧家庭 DEV',
    flavorName: 'dev',
    defaultApiUrl: 'https://test.hehome.xyz/graphql/',
    defaultAdminUrl: 'https://test.hehome.xyz/admin/',
  );
  bootstrap(appConfig);
}
