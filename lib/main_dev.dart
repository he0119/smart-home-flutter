import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:smarthome/app/app_config.dart';
import 'package:smarthome/app/simple_bloc_observer.dart';

import 'package:smarthome/app/configure_nonweb.dart'
    if (dart.library.html) 'package:smarthome/app/configure_web.dart';
import 'package:smarthome/app/main.dart';

Future<void> main() async {
  configureApp();
  Bloc.observer = SimpleBlocObserver();
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('[${record.level.name}] ${record.loggerName}'
        ' -- ${record.time} -- ${record.message}');
  });
  final configuredApp = AppConfig(
    appName: '智慧家庭 DEV',
    flavorName: 'dev',
    apiUrl: 'https://test.hehome.xyz/graphql',
    child: MyApp(),
  );
  await runZonedGuarded(() async {
    await SentryFlutter.init(
      (options) {
        options
          ..dsn =
              'https://dcc18c1b89d44e1894c4c712ea166c84@o480939.ingest.sentry.io/5685513'
          ..environment = 'dev';
      },
    );

    runApp(configuredApp);
  }, (exception, stackTrace) async {
    print('$exception, $stackTrace');
    await Sentry.captureException(exception, stackTrace: stackTrace);
  });
}
