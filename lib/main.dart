import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/pages/login_page.dart';

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
        } else if (state is Unauthenticated) {
          return LoginPage();
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
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
        child: Column(
          children: <Widget>[
            Text('欢迎'),
            FlatButton(
              child: Text('注销'),
              onPressed: () {
                BlocProvider.of<AuthenticationBloc>(context).add(AuthenticationLogout());
              },
            )
          ],
        ),
      ),
    );
  }
}
