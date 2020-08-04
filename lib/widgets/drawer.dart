import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/authentication/authentication_bloc.dart';
import 'package:smart_home/widgets/gravatar.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            if (state is AuthenticationSuccess) {
              return ListView(
                children: [
                  UserAccountsDrawerHeader(
                    accountName: Text(state.currentUser.username),
                    accountEmail: Text(state.currentUser.email),
                    currentAccountPicture:
                        CircleGravatar(email: state.currentUser.email),
                  ),
                  ListTile(
                    title: Text('设置'),
                    onTap: () {},
                  ),
                ],
              );
            }
            return Container();
          },
        ),
      ),
    );
  }
}
