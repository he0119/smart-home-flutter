import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/authentication/authentication_bloc.dart';
import 'package:smart_home/pages/settings/home_page.dart';
import 'package:smart_home/repositories/repositories.dart';
import 'package:smart_home/widgets/gravatar.dart';
import 'package:version/version.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          return ListView(
            children: [
              state is AuthenticationSuccess
                  ? UserAccountsDrawerHeader(
                      accountName: Text(state.currentUser.username),
                      accountEmail: Text(state.currentUser.email),
                      currentAccountPicture: CircleGravatar(
                        email: state.currentUser.email,
                        size: 512,
                      ),
                    )
                  : Container(),
              ListTile(
                title: Text('设置'),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => SettingsPage(),
                  ));
                },
              ),
              ListTile(
                title: Text('关于'),
                onTap: () async {
                  Version currentVersion =
                      await RepositoryProvider.of<VersionRepository>(context)
                          .currentVersion;
                  showAboutDialog(
                    context: context,
                    applicationVersion: currentVersion.toString(),
                    applicationIcon: ImageIcon(
                      AssetImage('assets/icon/icon.png'),
                      color: Color(0xFFF15713),
                    ),
                    applicationLegalese: '智慧家庭的客户端',
                  );
                },
              ),
              ListTile(
                title: Text('登出'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('登出'),
                      content: Text('确认登出账户？'),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('否'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        FlatButton(
                          child: Text('是'),
                          onPressed: () {
                            BlocProvider.of<AuthenticationBloc>(context)
                                .add(AuthenticationLogout());
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
