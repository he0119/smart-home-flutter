import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:smart_home/app_config.dart';
import 'package:smart_home/blocs/simple_bloc_observer.dart';

import 'main.dart';

void main() {
  Bloc.observer = SimpleBlocObserver();
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print(
        '[${record.level.name}] ${record.loggerName} -- ${record.time} -- ${record.message}');
  });
  var configuredApp = AppConfig(
    appName: '智慧家庭 DEV',
    flavorName: 'development',
    apiUrl: 'http://127.0.0.1:8000/graphql',
    child: MyApp(),
  );
  runApp(configuredApp);
}
