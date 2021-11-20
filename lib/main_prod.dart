import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:smarthome/app/configure_nonweb.dart'
    if (dart.library.html) 'package:smarthome/app/configure_web.dart';
import 'package:smarthome/app/main.dart';
import 'package:smarthome/core/repository/graphql_api_client.dart';
import 'package:smarthome/core/settings/settings_controller.dart';
import 'package:smarthome/core/settings/settings_service.dart';

import 'core/model/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureApp();

  // 应用的默认配置
  final appConfig = AppConfig(
    appName: '智慧家庭',
    flavorName: 'prod',
    defaultApiUrl: 'https://smart.hehome.xyz/graphql',
    defaultAdminUrl: 'https://smart.hehome.xyz/admin',
  );
  final settingsController = SettingsController(SettingsService(), appConfig);
  await settingsController.loadSettings();
  // 初始化 GraphQL API Client
  final graphQLApiClient = GraphQLApiClient(settingsController);
  await graphQLApiClient.initailize(settingsController.apiUrl);

  await runZonedGuarded(() async {
    await SentryFlutter.init(
      (options) {
        options
          ..dsn = ''
          ..environment = 'prod'
          ..release = 'release';
      },
    );

    runApp(
      MyApp(
        settingsController: settingsController,
        graphQLApiClient: graphQLApiClient,
      ),
    );
  }, (exception, stackTrace) async {
    await Sentry.captureException(exception, stackTrace: stackTrace);
  });
}
