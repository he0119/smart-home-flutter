import 'dart:async';

import 'package:smarthome/bootstrap.dart';
import 'package:smarthome/core/model/app_config.dart';

Future<void> main() async {
  // 应用的默认配置
  final appConfig = AppConfig(
    appName: '智慧家庭',
    flavorName: 'prod',
    defaultApiUrl: 'https://smart.hehome.xyz/graphql/',
    defaultAdminUrl: 'https://smart.hehome.xyz/admin/',
    defaultBlogUrl: 'https://hehome.xyz',
  );
  bootstrap(appConfig);
}
