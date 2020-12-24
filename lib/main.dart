import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:smart_home/app_config.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/blocs/board/blocs.dart';
import 'package:smart_home/blocs/push/push_bloc.dart';
import 'package:smart_home/blocs/storage/blocs.dart';
import 'package:smart_home/models/grobal_keys.dart';
import 'package:smart_home/repositories/iot_repository.dart';
import 'package:smart_home/repositories/push_repository.dart';
import 'package:smart_home/repositories/repositories.dart';
import 'package:smart_home/routers/delegate.dart';
import 'package:smart_home/routers/information_parser.dart';

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
    Key key,
  }) : super(key: key);

  @override
  _MyMaterialAppState createState() => _MyMaterialAppState();
}

class _MyMaterialAppState extends State<MyMaterialApp> {
  // 为了保存路由状态
  MyRouterDelegate _delegate = MyRouterDelegate();

  @override
  Widget build(BuildContext context) {
    final AppConfig config = AppConfig.of(context);
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
