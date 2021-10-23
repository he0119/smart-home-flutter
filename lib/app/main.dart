import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:smarthome/app/app_config.dart';
import 'package:smarthome/board/board.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/iot/iot.dart';
import 'package:smarthome/routers/delegate.dart';
import 'package:smarthome/routers/information_parser.dart';
import 'package:smarthome/storage/storage.dart';
import 'package:smarthome/user/user.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Intl.defaultLocale = 'zh';
    final graphQLApiClient = GraphQLApiClient();
    final userRepository = UserRepository(graphqlApiClient: graphQLApiClient);
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<GraphQLApiClient>(
          create: (context) => graphQLApiClient,
        ),
        RepositoryProvider<UserRepository>(
          create: (context) => userRepository,
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
          BlocProvider<AppPreferencesBloc>(
            create: (BuildContext context) =>
                AppPreferencesBloc()..add(AppStarted()),
          ),
          BlocProvider<AuthenticationBloc>(
            create: (context) => AuthenticationBloc(
              userRepository: RepositoryProvider.of<UserRepository>(context),
              graphqlApiClient:
                  RepositoryProvider.of<GraphQLApiClient>(context),
              appPreferencesBloc:
                  RepositoryProvider.of<AppPreferencesBloc>(context),
            ),
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
              appPreferencesBloc:
                  RepositoryProvider.of<AppPreferencesBloc>(context),
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
              boardRepository: RepositoryProvider.of<BoardRepository>(context),
            ),
          ),
        ],
        child: const MyMaterialApp(),
      ),
    );
  }
}

class MyMaterialApp extends StatefulWidget {
  const MyMaterialApp({
    Key? key,
  }) : super(key: key);

  @override
  _MyMaterialAppState createState() => _MyMaterialAppState();
}

class _MyMaterialAppState extends State<MyMaterialApp> {
  // 为了保存路由状态
  final MyRouterDelegate _delegate = MyRouterDelegate();

  @override
  void initState() {
    super.initState();
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
    final config = AppConfig.of(context);
    final themeMode = context.watch<AppPreferencesBloc>().state.themeMode;
    return MaterialApp.router(
      scaffoldMessengerKey: scaffoldMessengerKey,
      theme: ThemeData(),
      darkTheme: ThemeData.dark(),
      themeMode: themeMode,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
      ],
      title: config.appName,
      routeInformationParser: MyRouteInformationParser(),
      routerDelegate: _delegate,
    );
  }
}
