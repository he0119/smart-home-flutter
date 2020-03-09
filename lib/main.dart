import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:smart_home/app_config.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/pages/home_page.dart';
import 'package:smart_home/pages/login_page.dart';
import 'package:smart_home/pages/splash_page.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppConfig _config = AppConfig.of(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthenticationBloc>(
          create: (BuildContext context) =>
              AuthenticationBloc()..add(AppStarted(_config.apiUrl)),
        ),
        BlocProvider<StorageBloc>(
          create: (BuildContext context) => StorageBloc(),
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
        title: '智慧家庭',
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
                          .add(AppStarted(_config.apiUrl));
                    },
                  )
                ],
              ),
            );
          }
        }, builder: (context, state) {
          if (state is Authenticated) {
            return HomePage();
          }
          if (state is AppUninitialized) {
            return SplashPage();
          }
          return LoginPage();
        }),
      ),
    );
  }
}
