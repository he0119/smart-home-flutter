import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:smart_home/app_config.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/pages/board/topic_detail_page.dart';
import 'package:smart_home/pages/home_page.dart';
import 'package:smart_home/pages/login_page.dart';
import 'package:smart_home/pages/splash_page.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Intl.defaultLocale = 'zh';
    AppConfig config = AppConfig.of(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthenticationBloc>(
          create: (BuildContext context) =>
              AuthenticationBloc()..add(AppStarted(config.apiUrl)),
        ),
        BlocProvider<UpdateBloc>(
          create: (BuildContext context) => UpdateBloc()..add(UpdateStarted()),
        ),
        BlocProvider<SnackBarBloc>(
          create: (BuildContext context) => SnackBarBloc(),
        ),
        BlocProvider<TabBloc>(
          create: (BuildContext context) => TabBloc(),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
        ),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
        ],
        title: config.appName,
        onGenerateRoute: _generateRoute,
        home: BlocConsumer<AuthenticationBloc, AuthenticationState>(
          listener: (context, state) {
            if (state is AuthenticationError) {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('错误'),
                  content: Text(state.error),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('确认'),
                      onPressed: () {
                        Navigator.pop(context);
                        BlocProvider.of<AuthenticationBloc>(context)
                            .add(AppStarted(config.apiUrl));
                      },
                    )
                  ],
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is Authenticated) {
              BlocProvider.of<SnackBarBloc>(context).add(
                SnackBarChanged(
                    position: SnackBarPosition.home,
                    message: '登陆成功，欢迎 ${state.currentUser.username}',
                    type: MessageType.info),
              );
              return HomePage();
            }
            if (state is AppUninitialized) {
              return SplashPage();
            }
            return LoginPage();
          },
        ),
      ),
    );
  }
}

Route<dynamic> _generateRoute(RouteSettings settings) {
  if (settings.name == TopicDetailPage.routeName) {
    return MaterialPageRoute(
      builder: (context) {
        return TopicDetailPage(topicId: settings.arguments);
      },
    );
  }
  return null;
}
