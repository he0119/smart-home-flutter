import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:smarthome/app/app_config.dart';

import 'package:smarthome/app/configure_nonweb.dart'
    if (dart.library.html) 'package:smarthome/app/configure_web.dart';
import 'package:smarthome/app/main.dart';

Future<void> main() async {
  configureApp();
  final configuredApp = AppConfig(
    appName: '智慧家庭',
    flavorName: 'prod',
    apiUrl: 'https://smart.hehome.xyz/graphql',
    child: MyApp(),
  );
  await runZonedGuarded(() async {
    await SentryFlutter.init(
      (options) {
        options
          ..dsn =
              'https://dcc18c1b89d44e1894c4c712ea166c84@o480939.ingest.sentry.io/5685513'
          ..environment = 'prod';
      },
    );

    runApp(configuredApp);
  }, (exception, stackTrace) async {
    await Sentry.captureException(exception, stackTrace: stackTrace);
  });
}
