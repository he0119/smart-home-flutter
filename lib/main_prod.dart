import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:smart_home/app_config.dart';

import 'main.dart';

void main() {
  setUrlStrategy(PathUrlStrategy());
  var configuredApp = AppConfig(
    appName: '智慧家庭',
    flavorName: 'prod',
    apiUrl: 'https://smart.hehome.xyz/graphql',
    child: MyApp(),
  );
  runApp(configuredApp);
}
