import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:smarthome/app_config.dart';
import 'package:smarthome/blocs/core/blocs.dart';
import 'package:smarthome/board/bloc/blocs.dart';
import 'package:smarthome/blocs/storage/blocs.dart';
import 'package:smarthome/board/board_repository.dart';
import 'package:smarthome/models/grobal_keys.dart';
import 'package:smarthome/repositories/iot_repository.dart';
import 'package:smarthome/repositories/push_repository.dart';
import 'package:smarthome/repositories/repositories.dart';
import 'package:smarthome/routers/delegate.dart';
import 'package:smarthome/routers/information_parser.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Intl.defaultLocale = 'zh';
    GraphQLApiClient graphQLApiClient = GraphQLApiClient();
    UserRepository userRepository =
        UserRepository(graphqlApiClient: graphQLApiClient);
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
        child: MyMaterialApp(),
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
  MyRouterDelegate _delegate = MyRouterDelegate();

  @override
  void initState() {
    super.initState();
    // 仅在安卓上注册通道
    if (!kIsWeb && Platform.isAndroid) {
      MethodChannel('hehome.xyz/route').setMethodCallHandler(
        (call) async {
          if (call.method == 'RouteChanged' && call.arguments != null) {
            _delegate.navigateNewPath(call.arguments);
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppConfig config = AppConfig.of(context)!;
    return MaterialApp.router(
      scaffoldMessengerKey: scaffoldMessengerKey,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.white,
        accentColor: Color(0xFF56CCF2),
        iconTheme: IconThemeData(color: Color(0xFF255261)),
        bottomNavigationBarTheme:
            BottomNavigationBarThemeData(selectedItemColor: Color(0xFF2D9CDB)),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        accentColor: Color(0xFF2F80ED),
        bottomNavigationBarTheme:
            BottomNavigationBarThemeData(selectedItemColor: Color(0xFF2D9CDB)),
      ),
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
