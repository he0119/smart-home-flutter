import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/core/router/router_extensions.dart';
import 'package:smarthome/utils/launch_url.dart';
import 'package:smarthome/utils/show_confirm_dialog.dart';
import 'package:smarthome/widgets/avatar.dart';

class MyDrawer extends ConsumerWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final adminUrl = settings.adminUrl;
    final loginUser = settings.loginUser;
    final scheme = Theme.of(context).colorScheme;
    return Drawer(
      child: ListView(
        children: [
          if (loginUser != null)
            UserAccountsDrawerHeader(
              // 用 container 配色：直接拿 primary 铺满会变成浅底浅字
              decoration: BoxDecoration(color: scheme.primaryContainer),
              accountName: Text(
                loginUser.username,
                style: TextStyle(color: scheme.onPrimaryContainer),
              ),
              accountEmail: Text(
                loginUser.email!,
                style: TextStyle(color: scheme.onPrimaryContainer),
              ),
              currentAccountPicture: MyCircleAvatar(
                avatarUrl: loginUser.avatarUrl,
              ),
            ),
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: const Text('耗材管理'),
            onTap: () {
              context.goConsumables();
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('回收站'),
            onTap: () {
              context.goRecycleBin();
            },
          ),
          ListTile(
            leading: const Icon(Icons.admin_panel_settings_outlined),
            title: const Text('管理'),
            onTap: () {
              if (!kIsWeb && !Platform.isWindows) {
                context.goAdmin();
              } else {
                launchUrl(adminUrl);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('设置'),
            onTap: () {
              context.goSettings();
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('关于'),
            onTap: () async {
              final versionRepository = ref.read(versionRepositoryProvider);
              final currentVersion = await versionRepository.currentVersion;
              if (context.mounted) {
                showAboutDialog(
                  context: context,
                  applicationVersion: currentVersion.toString(),
                  applicationIcon: const ImageIcon(
                    AssetImage('assets/icon/icon.webp'),
                    color: Color(0xFFF15713),
                  ),
                  applicationLegalese: '智慧家庭的客户端',
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('登出'),
            onTap: () async {
              final confirmed = await showConfirmDialog(
                context,
                title: '登出',
                message: '确认退出当前账号？',
                confirmLabel: '登出',
                destructive: true,
              );
              if (!confirmed) {
                return;
              }
              ref.read(authenticationProvider.notifier).logout();
            },
          ),
        ],
      ),
    );
  }
}
