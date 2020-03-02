import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/blocs.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        print('home: $state');
        if (state is Unauthenticated) {
          Navigator.of(context).pushNamed('/login');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('首页'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              FlatButton(
                child: Text('注销'),
                onPressed: () {
                  BlocProvider.of<AuthenticationBloc>(context)
                      .add(AuthenticationLogout());
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
