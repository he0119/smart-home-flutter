import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:smarthome/app/app_config.dart';

import 'package:smarthome/app/configure_nonweb.dart'
    if (dart.library.html) 'package:smarthome/app/configure_web.dart';
import 'package:smarthome/app/main.dart';
import 'package:smarthome/core/settings/settings_controller.dart';
import 'package:smarthome/core/settings/settings_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureApp();
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();
  final configuredApp = AppConfig(
    appName: '智慧家庭',
    flavorName: 'prod',
    apiUrl: 'https://smart.hehome.xyz/graphql',
    child: MyApp(
      settingsController: settingsController,
    ),
  );
  await runZonedGuarded(() async {
    await SentryFlutter.init(
      (options) {
        options
          ..dsn = ''
          ..environment = 'prod'
          ..release = 'release';
      },
    );

    runApp(configuredApp);
  }, (exception, stackTrace) async {
    await Sentry.captureException(exception, stackTrace: stackTrace);
  });
}
