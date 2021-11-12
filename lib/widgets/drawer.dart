import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/routers/delegate.dart';
import 'package:smarthome/storage/storage.dart';
import 'package:smarthome/widgets/avatar.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);

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
                  accountEmail: Text(state.currentUser.email!),
                  currentAccountPicture: MyCircleAvatar(
                    avatarUrl: state.currentUser.avatarUrl,
                  ),
                ),
              ListTile(
                title: const Text('耗材管理'),
                onTap: () {
                  MyRouterDelegate.of(context).push(ConsumablesPage());
                },
              ),
              ListTile(
                title: const Text('回收站'),
                onTap: () {
                  MyRouterDelegate.of(context).push(RecycleBinPage());
                },
              ),
              ListTile(
                title: const Text('设置'),
                onTap: () {
                  MyRouterDelegate.of(context).push(const SettingsPage());
                },
              ),
              ListTile(
                title: const Text('关于'),
                onTap: () async {
                  final currentVersion =
                      await RepositoryProvider.of<VersionRepository>(context)
                          .currentVersion;
                  showAboutDialog(
                    context: context,
                    applicationVersion: currentVersion.toString(),
                    applicationIcon: const ImageIcon(
                      AssetImage('assets/icon/icon.webp'),
                      color: Color(0xFFF15713),
                    ),
                    applicationLegalese: '智慧家庭的客户端',
                  );
                },
              ),
              ListTile(
                title: const Text('登出'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('登出'),
                      content: const Text('确认登出账户？'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('否'),
                        ),
                        TextButton(
                          onPressed: () {
                            BlocProvider.of<AuthenticationBloc>(context)
                                .add(AuthenticationLogout());
                            Navigator.pop(context);
                          },
                          child: const Text('是'),
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
