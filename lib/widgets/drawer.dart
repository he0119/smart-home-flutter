import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthome/app/settings/settings_controller.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/core/view/admin_page.dart';
import 'package:smarthome/routers/delegate.dart';
import 'package:smarthome/storage/storage.dart';
import 'package:smarthome/utils/launch_url.dart';
import 'package:smarthome/widgets/avatar.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final adminUrl =
        context.select((SettingsController settings) => settings.adminUrl);
    final loginUser =
        context.select((SettingsController settings) => settings.loginUser);
    return Drawer(
      child: ListView(
        children: [
          if (loginUser != null)
            UserAccountsDrawerHeader(
              accountName: Text(
                loginUser.username,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground),
              ),
              accountEmail: Text(loginUser.email!,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground)),
              currentAccountPicture: MyCircleAvatar(
                avatarUrl: loginUser.avatarUrl,
              ),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background),
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
            title: const Text('管理'),
            onTap: () {
              if (!kIsWeb && !Platform.isWindows) {
                MyRouterDelegate.of(context).push(const AdminPage());
              } else {
                launchUrl(adminUrl);
              }
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
                        context
                            .read<AuthenticationBloc>()
                            .add(AuthenticationLogout());
                        Navigator.of(context).pop();
                      },
                      child: const Text('是'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
