import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:smarthome/app/configure_nonweb.dart'
    if (dart.library.html) 'package:smarthome/app/configure_web.dart';
import 'package:smarthome/app/main.dart';
import 'package:smarthome/app/settings/settings_controller.dart';
import 'package:smarthome/app/settings/settings_service.dart';
import 'package:smarthome/app/simple_riverpod_observer.dart';
import 'package:smarthome/core/model/app_config.dart';
import 'package:smarthome/core/providers/settings_provider.dart';
import 'package:smarthome/core/repository/graphql_api_client.dart';

Future<void> bootstrap(AppConfig appConfig) async {
  await SentryFlutter.init(
    (options) {
      options
        ..dsn = const String.fromEnvironment('SENTRY_DSN', defaultValue: '')
        ..environment = appConfig.flavorName
        ..release = const String.fromEnvironment('SENTRY_RELEASE');
    },
    appRunner: () async {
      WidgetsFlutterBinding.ensureInitialized();
      // 设置导航栏透明
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.transparent,
        ),
      );
      // 根据是否是网页环境，初始化不同的配置
      await configureApp();

      // 初始化服务和配置
      final settingsService = SettingsService();

      // 为了向后兼容，暂时保留旧的 SettingsController
      // TODO: 完全迁移后可以删除
      final settingsController = SettingsController(settingsService, appConfig);
      await settingsController.loadSettings();

      // 初始化 GraphQL API Client
      final graphQLApiClient = GraphQLApiClient(settingsController);
      await graphQLApiClient.loadSettings();

      // 创建 ProviderContainer 并配置 Riverpod Observer
      final container = ProviderContainer(
        observers: [SimpleRiverpodObserver()],
        overrides: [
          settingsServiceProvider.overrideWithValue(settingsService),
          appConfigProvider.overrideWithValue(appConfig),
        ],
      );

      // 加载设置到 Riverpod provider
      await container.read(settingsProvider.notifier).loadSettings();

      runApp(
        UncontrolledProviderScope(
          container: container,
          child: MyApp(
            settingsController: settingsController,
            graphQLApiClient: graphQLApiClient,
          ),
        ),
      );
    },
  );
}
