import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:smarthome/app/app_config.dart';
import 'package:smarthome/app/configure_nonweb.dart'
    if (dart.library.html) 'package:smarthome/app/configure_web.dart';
import 'package:smarthome/app/main.dart';
import 'package:smarthome/app/simple_bloc_observer.dart';
import 'package:smarthome/core/repository/graphql_api_client.dart';
import 'package:smarthome/core/settings/settings_controller.dart';
import 'package:smarthome/core/settings/settings_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureApp();
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print('[${record.level.name}] ${record.loggerName}'
        ' -- ${record.time} -- ${record.message}');
  });
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(
    SettingsService(
      defaultApiUrl: 'https://test.hehome.xyz/graphql',
      defaultAdminUrl: 'https://test.hehome.xyz/admin',
    ),
  );
  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();
  // 初始化 GraphQL API Client
  final graphQLApiClient = GraphQLApiClient();
  await graphQLApiClient.initailize(settingsController.apiUrl);

  final configuredApp = AppConfig(
    appName: '智慧家庭 DEV',
    flavorName: 'dev',
    child: MyApp(
      settingsController: settingsController,
      graphQLApiClient: graphQLApiClient,
    ),
  );

  await runZonedGuarded(
    () async {
      await SentryFlutter.init(
        (options) {
          options
            ..dsn = ''
            ..environment = 'dev'
            ..release = 'release';
        },
      );
      BlocOverrides.runZoned(
        () {
          runApp(configuredApp);
        },
        blocObserver: SimpleBlocObserver(),
      );
    },
    (exception, stackTrace) async {
      // ignore: avoid_print
      print('$exception, $stackTrace');
      await Sentry.captureException(exception, stackTrace: stackTrace);
    },
  );
}
