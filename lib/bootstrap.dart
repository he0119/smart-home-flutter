import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:smarthome/app/configure_nonweb.dart'
    if (dart.library.html) 'package:smarthome/app/configure_web.dart';
import 'package:smarthome/app/main.dart';
import 'package:smarthome/app/settings/settings_controller.dart';
import 'package:smarthome/app/settings/settings_service.dart';
import 'package:smarthome/app/simple_bloc_observer.dart';
import 'package:smarthome/core/model/app_config.dart';
import 'package:smarthome/core/repository/graphql_api_client.dart';

Future<void> bootstrap(AppConfig appConfig) async {
  WidgetsFlutterBinding.ensureInitialized();
  // 设置导航栏透明
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
  ));
  // 根据是否是网页环境，初始化不同的配置
  await configureApp();
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService(), appConfig);
  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();
  // 初始化 GraphQL API Client
  final graphQLApiClient = GraphQLApiClient(settingsController);
  await graphQLApiClient.loadSettings();
  // 配置 BLoC 的日志
  Bloc.observer = SimpleBlocObserver();

  await SentryFlutter.init(
    (options) {
      options
        ..dsn = ''
        ..environment = 'dev'
        ..release = 'release';
    },
    appRunner: () => runApp(
      MyApp(
        settingsController: settingsController,
        graphQLApiClient: graphQLApiClient,
      ),
    ),
  );
}
