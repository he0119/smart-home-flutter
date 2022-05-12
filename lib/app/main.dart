import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:smarthome/app/settings/settings_controller.dart';
import 'package:smarthome/board/board.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/iot/iot.dart';
import 'package:smarthome/l10n/l10n.dart';
import 'package:smarthome/routers/delegate.dart';
import 'package:smarthome/routers/information_parser.dart';
import 'package:smarthome/storage/storage.dart';
import 'package:smarthome/user/user.dart';

class MyApp extends StatelessWidget {
  MyApp({
    Key? key,
    required this.settingsController,
    required this.graphQLApiClient,
  }) : super(key: key) {
    // 在应用最开始用设置里的 API URL 初始化 GraphQLClient
    graphQLApiClient.initailize(settingsController.apiUrl ??
        settingsController.appConfig.defaultApiUrl);
  }

  final SettingsController settingsController;
  final GraphQLApiClient graphQLApiClient;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: settingsController,
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider<GraphQLApiClient>.value(
            value: graphQLApiClient,
          ),
          RepositoryProvider<UserRepository>(
            create: (context) =>
                UserRepository(graphqlApiClient: graphQLApiClient),
          ),
          RepositoryProvider<VersionRepository>(
            create: (context) => VersionRepository(),
          ),
          RepositoryProvider<PushRepository>(
            create: (context) =>
                PushRepository(graphqlApiClient: graphQLApiClient),
          ),
          RepositoryProvider<StorageRepository>(
            create: (context) =>
                StorageRepository(graphqlApiClient: graphQLApiClient),
          ),
          RepositoryProvider<BoardRepository>(
            create: (context) =>
                BoardRepository(graphqlApiClient: graphQLApiClient),
          ),
          RepositoryProvider<IotRepository>(
            create: (context) =>
                IotRepository(graphqlApiClient: graphQLApiClient),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthenticationBloc>(
              create: (context) => AuthenticationBloc(
                userRepository: RepositoryProvider.of<UserRepository>(context),
                graphqlApiClient:
                    RepositoryProvider.of<GraphQLApiClient>(context),
                settingsController: settingsController,
              )..add(AuthenticationStarted()),
            ),
            BlocProvider<TabBloc>(
              create: (context) => TabBloc(),
            ),
            BlocProvider<UpdateBloc>(
              create: (context) => UpdateBloc(
                versionRepository:
                    RepositoryProvider.of<VersionRepository>(context),
              )..add(UpdateStarted()),
            ),
            BlocProvider<PushBloc>(
              create: (context) => PushBloc(
                pushRepository: RepositoryProvider.of<PushRepository>(context),
                settingsController: settingsController,
              ),
            ),
            BlocProvider<StorageHomeBloc>(
              create: (context) => StorageHomeBloc(
                storageRepository:
                    RepositoryProvider.of<StorageRepository>(context),
              ),
            ),
            BlocProvider<BoardHomeBloc>(
              create: (context) => BoardHomeBloc(
                boardRepository:
                    RepositoryProvider.of<BoardRepository>(context),
              ),
            ),
          ],
          child: MyMaterialApp(settingsController: settingsController),
        ),
      ),
    );
  }
}

class MyMaterialApp extends StatefulWidget {
  final SettingsController settingsController;

  const MyMaterialApp({
    Key? key,
    required this.settingsController,
  }) : super(key: key);

  @override
  State<MyMaterialApp> createState() => _MyMaterialAppState();
}

class _MyMaterialAppState extends State<MyMaterialApp> {
  // 为了保存路由状态
  late final MyRouterDelegate _delegate;

  @override
  void initState() {
    super.initState();
    _delegate = MyRouterDelegate(settingsController: widget.settingsController);
    // 仅在安卓上注册通道
    if (!kIsWeb && Platform.isAndroid) {
      const MethodChannel('hehome.xyz/route').setMethodCallHandler(
        (call) async {
          if (call.method == 'RouteChanged' && call.arguments != null) {
            await _delegate.navigateNewPath(call.arguments as String);
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode =
        context.select((SettingsController settings) => settings.themeMode);
    return MaterialApp.router(
      scaffoldMessengerKey: scaffoldMessengerKey,
      theme: ThemeData(
        primaryColor: Colors.white,
        appBarTheme: const AppBarTheme(
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData.dark(),
      themeMode: themeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      title: widget.settingsController.appConfig.appName,
      routeInformationParser: MyRouteInformationParser(),
      routerDelegate: _delegate,
    );
  }
}
