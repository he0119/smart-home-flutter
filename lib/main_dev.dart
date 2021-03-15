import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:smarthome/app_config.dart';
import 'package:smarthome/blocs/simple_bloc_observer.dart';

import 'configure_nonweb.dart' if (dart.library.html) 'configure_web.dart';
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
    apiUrl: 'https://test.hehome.xyz/graphql',
    child: MyApp(),
  );
  runApp(configuredApp);
}
