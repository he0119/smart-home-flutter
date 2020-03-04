import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/blocs/simple_bloc_delegate.dart';
import 'package:smart_home/pages/home_page.dart';
import 'package:smart_home/pages/login_page.dart';
import 'package:smart_home/pages/splash_page.dart';

void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthenticationBloc>(
          create: (BuildContext context) =>
              AuthenticationBloc()..add(AppStarted()),
        ),
        BlocProvider<StorageSearchBloc>(
          create: (BuildContext context) => StorageSearchBloc(),
        ),
        BlocProvider<StorageBloc>(
          create: (BuildContext context) => StorageBloc(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
        if (state is Authenticated) {
          return HomePage();
        }
        if (state is AppUninitialized) {
          return SplashPage();
        }
        return LoginPage();
      }),
    );
  }
}
