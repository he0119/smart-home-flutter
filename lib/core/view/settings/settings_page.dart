import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/core/router/app_router.dart';
import 'package:smarthome/core/view/settings/mipush_settings_tile.dart';
import 'package:smarthome/user/providers/session_provider.dart';
import 'package:smarthome/utils/theme_mode_extension.dart';
import 'package:smarthome/widgets/home_page.dart';
import 'package:smarthome/widgets/settings/settings.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsScreen();
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return MySliverScaffold(
      title: const Text('设置'),
      sliver: SettingsList(
        sections: [
          SettingsSection(
            title: '通用',
            tiles: [
              SettingsTile(
                leading: Icons.palette_outlined,
                title: '主题',
                subtitle: settings.themeMode.toReadable(),
                onPressed: (context) {
                  context.push(AppRoutes.themeSettings);
                },
              ),
              SettingsTile(
                leading: Icons.dns_outlined,
                title: '服务器网址',
                subtitle: settings.apiUrl,
                onPressed: (context) {
                  context.push(AppRoutes.apiUrlSettings);
                },
              ),
              SettingsTile(
                leading: Icons.admin_panel_settings_outlined,
                title: '管理网址',
                subtitle: settings.adminUrl,
                onPressed: (context) {
                  context.push(AppRoutes.adminUrlSettings);
                },
              ),
              SettingsTile(
                leading: Icons.home_outlined,
                title: '默认主页',
                subtitle: settings.defaultPage.name,
                onPressed: (context) {
                  context.push(AppRoutes.defaultPageSettings);
                },
              ),
              if (!kIsWeb && Platform.isAndroid) const MiPushSettingsTile(),
              SettingsTile(
                leading: Icons.devices_outlined,
                title: '登录设备管理',
                subtitle: '查看并移除已登录的设备',
                onPressed: (context) {
                  // 初始化 session provider 并导航到 SessionPage
                  ref.read(sessionProvider.notifier).fetchSessions();
                  context.push(AppRoutes.sessionSettings);
                },
              ),
            ],
          ),
          SettingsSection(
            title: '博客',
            tiles: [
              SettingsTile(
                leading: Icons.link,
                title: '博客网址',
                subtitle: settings.blogUrl,
                onPressed: (context) {
                  context.push(AppRoutes.blogUrlSettings);
                },
              ),
              SettingsTile(
                leading: Icons.admin_panel_settings_outlined,
                title: '博客管理网址',
                subtitle: settings.blogAdminUrl ?? '请单击输入',
                onPressed: (context) {
                  context.push(AppRoutes.blogAdminUrlSettings);
                },
              ),
            ],
          ),
          SettingsSection(
            title: '留言板',
            tiles: [
              SettingsTile(
                leading: Icons.sort,
                title: '评论排序',
                subtitle: settings.commentDescending ? '倒序' : '正序',
                onPressed: (context) {
                  context.push(AppRoutes.commentOrderSettings);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
