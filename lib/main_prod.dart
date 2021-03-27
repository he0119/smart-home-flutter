import 'package:flutter/material.dart';
import 'package:smarthome/app/app_config.dart';

import 'package:smarthome/app/configure_nonweb.dart'
    if (dart.library.html) 'package:smarthome/app/configure_web.dart';
import 'package:smarthome/app/main.dart';

void main() {
  configureApp();
  var configuredApp = AppConfig(
    appName: '智慧家庭',
    flavorName: 'prod',
    apiUrl: 'https://smart.hehome.xyz/graphql',
    child: MyApp(),
  );
  runApp(configuredApp);
}
