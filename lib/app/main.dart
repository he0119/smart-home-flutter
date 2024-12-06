import 'dart:io';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smarthome/app/settings/settings_controller.dart';
import 'package:smarthome/blog/blog.dart';
import 'package:smarthome/board/board.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/iot/bloc/blocs.dart';
import 'package:smarthome/iot/iot.dart';
import 'package:smarthome/l10n/l10n.dart';
import 'package:smarthome/storage/storage.dart';
import 'package:smarthome/user/user.dart';

class MyApp extends StatelessWidget {
  MyApp({
    super.key,
    required this.settingsController,
    required this.graphQLApiClient,
  }) {
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
    super.key,
    required this.settingsController,
  });

  @override
  State<MyMaterialApp> createState() => _MyMaterialAppState();
}

class _MyMaterialAppState extends State<MyMaterialApp> {
  // 为了保存路由状态
  final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/storage',
        builder: (context, state) {
          BlocProvider.of<StorageHomeBloc>(context)
              .add(const StorageHomeFetched(itemType: ItemType.all));
          return const StorageHomeScreen();
        },
      ),
      GoRoute(
        path: '/iot',
        builder: (context, state) {
          BlocProvider.of<StorageHomeBloc>(context)
              .add(const StorageHomeFetched(itemType: ItemType.all));
          return MultiBlocProvider(
            providers: [
              BlocProvider<DeviceDataBloc>(
                // 因为只有一个设备就先写死
                create: (context) => DeviceDataBloc(
                  iotRepository: RepositoryProvider.of<IotRepository>(context),
                  deviceId: 'RGV2aWNlOjE=',
                  client: RepositoryProvider.of<GraphQLApiClient>(context),
                )..add(const DeviceDataStarted()),
              ),
              BlocProvider<DeviceEditBloc>(
                create: (context) => DeviceEditBloc(
                  iotRepository: RepositoryProvider.of<IotRepository>(context),
                ),
              ),
            ],
            child: const IotHomeScreen(),
          );
        },
      ),
      GoRoute(
        path: '/blog',
        builder: (context, state) {
          BlocProvider.of<StorageHomeBloc>(context)
              .add(const StorageHomeFetched(itemType: ItemType.all));
          return const BlogHomeScreen();
        },
      ),
      GoRoute(
        path: '/board',
        builder: (context, state) {
          BlocProvider.of<StorageHomeBloc>(context)
              .add(const StorageHomeFetched(itemType: ItemType.all));
          return const BoardHomeScreen();
        },
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final settingsController = context.watch<SettingsController>();
      if (!settingsController.isLogin) {
        if (state.matchedLocation == '/login') {
          return null;
        }
        return '/login?redirect=${state.uri.toString()}';
      } else {
        if (state.uri.toString() == '/') {
          return settingsController.defaultPage.path;
        }
        if (state.matchedLocation == '/login') {
          if (state.uri.queryParameters['redirect'] != null) {
            return state.uri.queryParameters['redirect'];
          } else {
            // 如果是登录状态，但是访问的是登录页面，那么就跳转到默认页面
            return settingsController.defaultPage.path;
          }
        }
        return null;
      }
    },
  );

  @override
  void initState() {
    super.initState();
    // 仅在安卓上注册通道
    if (!kIsWeb && Platform.isAndroid) {
      const MethodChannel('hehome.xyz/route').setMethodCallHandler(
        (call) async {
          if (call.method == 'RouteChanged' && call.arguments != null) {
            _router.go(call.arguments as String);
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode =
        context.select((SettingsController settings) => settings.themeMode);
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp.router(
          scaffoldMessengerKey: scaffoldMessengerKey,
          theme: ThemeData(
            colorScheme: lightDynamic,
            useMaterial3: true,
          ),
          darkTheme: ThemeData.dark().copyWith(
            colorScheme: darkDynamic,
          ),
          themeMode: themeMode,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          title: widget.settingsController.appConfig.appName,
          routerConfig: _router,
        );
      },
    );
  }
}
