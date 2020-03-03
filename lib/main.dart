import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/blocs/simple_bloc_delegate.dart';
import 'package:smart_home/pages/home_page.dart';
import 'package:smart_home/pages/login_page.dart';

void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  runApp(
    BlocProvider(
      create: (context) => AuthenticationBloc()..add(AppStarted()),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => HomePage(),
        '/login': (context) => LoginPage(),
      },
      initialRoute: '/',
    );
  }
}
