import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:smart_home/app_config.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/blocs/board/blocs.dart';
import 'package:smart_home/blocs/storage/blocs.dart';
import 'package:smart_home/pages/home_page.dart';
import 'package:smart_home/pages/splash_page.dart';
import 'package:smart_home/repositories/iot_repository.dart';
import 'package:smart_home/repositories/repositories.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Intl.defaultLocale = 'zh';
    AppConfig config = AppConfig.of(context);
    GraphQLApiClient graphQLApiClient = GraphQLApiClient();
    UserRepository userRepository =
        UserRepository(graphqlApiClient: graphQLApiClient);
    graphQLApiClient.userRepository = userRepository;
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
          BlocProvider<SnackBarBloc>(
            create: (context) => SnackBarBloc(),
          ),
          BlocProvider<UpdateBloc>(
            create: (context) => UpdateBloc(
              versionRepository:
                  RepositoryProvider.of<VersionRepository>(context),
            )..add(UpdateStarted()),
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
        child: MaterialApp(
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: Colors.white,
            accentColor: Color(0xFF56CCF2),
            iconTheme: IconThemeData(color: Color(0xFF255261)),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
                selectedItemColor: Color(0xFF2D9CDB)),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            accentColor: Color(0xFF2F80ED),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
                selectedItemColor: Color(0xFF2D9CDB)),
          ),
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: [
            const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
          ],
          title: config.appName,
          home: BlocConsumer<AppPreferencesBloc, AppPreferencesState>(
            listenWhen: (previous, current) {
              // 如果 APIURL 发生变化则初始化 GraphQL 客户端
              // 如果客户端还未初始化，也自动初始化
              if (previous.apiUrl != current.apiUrl) {
                return true;
              } else if (graphQLApiClient.client == null) {
                return true;
              } else {
                return false;
              }
            },
            listener: (context, state) {
              // 如果软件配置中没有设置过 APIURL，则使用默认的 URL
              graphQLApiClient.initailize(state.apiUrl ?? config.apiUrl);
            },
            builder: (context, state) {
              if (!state.initialized) {
                return SplashPage();
              }
              return BlocProvider<TabBloc>(
                create: (context) => TabBloc(defaultTab: state.defaultPage)
                  ..add(TabChanged(state.defaultPage)),
                child: HomePage(),
              );
            },
          ),
        ),
      ),
    );
  }
}
