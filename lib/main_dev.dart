import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:smart_home/app_config.dart';
import 'package:smart_home/blocs/simple_bloc_observer.dart';

import 'main.dart';

void main() {
  configureApp();
  Bloc.observer = SimpleBlocObserver();
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print(
        '[${record.level.name}] ${record.loggerName} -- ${record.time} -- ${record.message}');
  });
  var configuredApp = AppConfig(
    appName: '智慧家庭 DEV',
    flavorName: 'dev',
    apiUrl: 'https://smart-test.hehome.xyz/graphql',
    child: MyApp(),
  );
  runApp(configuredApp);
}
