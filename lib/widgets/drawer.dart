import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/core/blocs.dart';
import 'package:smart_home/pages/settings/settings_page.dart';
import 'package:smart_home/pages/storage/consumables_page.dart';
import 'package:smart_home/pages/storage/recycle_bin_page.dart';
import 'package:smart_home/repositories/repositories.dart';
import 'package:smart_home/routers/delegate.dart';
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
              if (state is AuthenticationSuccess)
                UserAccountsDrawerHeader(
                  accountName: Text(state.currentUser.username),
                  accountEmail: Text(state.currentUser.email),
                  currentAccountPicture: CircleGravatar(
                    email: state.currentUser.email,
                    size: 512,
                  ),
                ),
              ListTile(
                title: Text('耗材管理'),
                onTap: () {
                  MyRouterDelegate.of(context).push(ConsumablesPage());
                },
              ),
              ListTile(
                title: Text('回收站'),
                onTap: () {
                  MyRouterDelegate.of(context).push(RecycleBinPage());
                },
              ),
              ListTile(
                title: Text('设置'),
                onTap: () {
                  MyRouterDelegate.of(context).push(SettingsPage());
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
                      AssetImage('assets/icon/icon.webp'),
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
