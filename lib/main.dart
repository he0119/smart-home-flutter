import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/screens/login.dart';

import 'authentication/authentication_bloc.dart';

void main() => runApp(
      BlocProvider(
        create: (context) => AuthenticationBloc()..add(AppStarted()),
        child: MyApp(),
      ),
    );

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
        print(state);
        if (state is Authenticated) {
          return HomePage();
        }
        if (state is Unauthenticated) {
          return LoginPage();
        }
        return HomePage();
      }),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('首页'),
      ),
      body: Center(
        child: Text('欢迎'),
      ),
    );
  }
}
