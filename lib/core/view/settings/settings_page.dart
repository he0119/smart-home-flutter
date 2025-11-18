import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
                title: '主题',
                subtitle: settings.themeMode.toReadable(),
                onPressed: (context) {
                  context.push(AppRoutes.themeSettings);
                },
              ),
              SettingsTile(
                title: '服务器网址',
                subtitle: settings.apiUrl,
                onPressed: (context) {
                  context.push(AppRoutes.apiUrlSettings);
                },
              ),
              SettingsTile(
                title: '管理网址',
                subtitle: settings.adminUrl,
                onPressed: (context) {
                  context.push(AppRoutes.adminUrlSettings);
                },
              ),
              SettingsTile(
                title: '默认主页',
                subtitle: settings.defaultPage.name,
                onPressed: (context) {
                  context.push(AppRoutes.defaultPageSettings);
                },
              ),
              if (!kIsWeb && Platform.isAndroid) const MiPushSettingsTile(),
              SettingsTile(
                title: '登陆设备管理',
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
                title: '博客网址',
                subtitle: settings.blogUrl,
                onPressed: (context) {
                  context.push(AppRoutes.blogUrlSettings);
                },
              ),
              SettingsTile(
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
