import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/blog/blog.dart';
import 'package:smarthome/board/board.dart';
import 'package:smarthome/core/model/app_tab.dart';
import 'package:smarthome/core/providers/settings_provider.dart';
import 'package:smarthome/core/view/settings/admin_url_page.dart';
import 'package:smarthome/core/view/settings/api_url_page.dart';
import 'package:smarthome/core/view/settings/default_page.dart';
import 'package:smarthome/core/view/settings/mipush_settings_tile.dart';
import 'package:smarthome/core/view/settings/session_page.dart';
import 'package:smarthome/core/view/settings/theme_mode.dart';
import 'package:smarthome/user/providers/session_provider.dart';
import 'package:smarthome/utils/theme_mode_extension.dart';
import 'package:smarthome/widgets/home_page.dart';
import 'package:smarthome/widgets/settings/settings.dart';

class SettingsPage extends Page {
  const SettingsPage()
    : super(key: const ValueKey('settings'), name: '/settings');

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (context) => const SettingsScreen(),
    );
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
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ThemeModePage(),
                    ),
                  );
                },
              ),
              SettingsTile(
                title: '服务器网址',
                subtitle: settings.apiUrl,
                onPressed: (context) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const ApiUrlPage()),
                  );
                },
              ),
              SettingsTile(
                title: '管理网址',
                subtitle: settings.adminUrl,
                onPressed: (context) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AdminUrlPage(),
                    ),
                  );
                },
              ),
              SettingsTile(
                title: '默认主页',
                subtitle: settings.defaultPage.name,
                onPressed: (context) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const DefaultPage(),
                    ),
                  );
                },
              ),
              if (!kIsWeb && Platform.isAndroid) const MiPushSettingsTile(),
              SettingsTile(
                title: '登陆设备管理',
                onPressed: (context) {
                  // 初始化 session provider 并导航到 SessionPage
                  ref.read(sessionProvider.notifier).fetchSessions();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SessionPage(),
                    ),
                  );
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
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const BlogUrlPage(),
                    ),
                  );
                },
              ),
              SettingsTile(
                title: '博客管理网址',
                subtitle: settings.blogAdminUrl ?? '请单击输入',
                onPressed: (context) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const BlogAdminUrlPage(),
                    ),
                  );
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
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CommentOrderPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
