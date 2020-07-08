import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:smart_home/app_config.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/pages/home_page.dart';
import 'package:smart_home/pages/splash_page.dart';
import 'package:smart_home/repositories/graphql_api_client.dart';
import 'package:smart_home/repositories/user_repository.dart';
import 'package:smart_home/repositories/version_repository.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Intl.defaultLocale = 'zh';
    AppConfig config = AppConfig.of(context);
    GraphQLApiClient graphQLApiClient = GraphQLApiClient();
    UserRepository userRepository =
        UserRepository(graphqlApiClient: graphQLApiClient);
    return BlocProvider<AppPreferencesBloc>(
      create: (BuildContext context) => AppPreferencesBloc()..add(AppStarted()),
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
        home: MultiRepositoryProvider(
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
          ],
          child: BlocConsumer<AppPreferencesBloc, AppPreferencesState>(
            listenWhen: (previous, current) {
              if (previous.apiUrl != current.apiUrl) {
                return true;
              } else if (graphQLApiClient.client == null) {
                return true;
              } else {
                return false;
              }
            },
            listener: (context, state) {
              graphQLApiClient.initailize(
                url: state.apiUrl ?? config.apiUrl,
                userRepository: userRepository,
              );
            },
            builder: (context, state) {
              if (!state.initialized) {
                return SplashPage();
              }
              return HomePage();
            },
          ),
        ),
      ),
    );
  }
}
