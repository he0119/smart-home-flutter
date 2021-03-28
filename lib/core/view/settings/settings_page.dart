import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:smarthome/blog/blog.dart';
import 'package:smarthome/board/board.dart';
import 'package:smarthome/core/bloc/blocs.dart';
import 'package:smarthome/core/model/models.dart';
import 'package:smarthome/core/view/settings/api_url_page.dart';
import 'package:smarthome/core/view/settings/default_page.dart';
import 'package:smarthome/core/view/settings/mipush_settings_tile.dart';
import 'package:smarthome/iot/iot.dart';

class SettingsPage extends Page {
  SettingsPage() : super(key: const ValueKey('settings'), name: '/settings');

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (context) => const SettingsScreen(),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: BlocBuilder<AppPreferencesBloc, AppPreferencesState>(
        builder: (context, state) => SettingsList(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
          sections: [
            SettingsSection(
              title: '通用',
              tiles: [
                SettingsTile(
                  title: '服务器网址',
                  subtitle: state.apiUrl ?? '请单击输入',
                  onPressed: (context) {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const ApiUrlPage(),
                    ));
                  },
                ),
                SettingsTile(
                  title: '默认主页',
                  subtitle: state.defaultPage.name,
                  onPressed: (context) {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const DefaultPage(),
                    ));
                  },
                ),
                if (!kIsWeb && Platform.isAndroid) MiPushSettingsTile(),
              ],
            ),
            SettingsSection(
              title: '物联网',
              tiles: [
                SettingsTile(
                  title: '刷新间隔',
                  subtitle: state.refreshInterval.toString(),
                  onPressed: (context) {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const RefreshIntervalPage(),
                    ));
                  },
                ),
              ],
            ),
            SettingsSection(
              title: '博客',
              tiles: [
                SettingsTile(
                  title: '博客网址',
                  subtitle: state.blogUrl,
                  onPressed: (context) {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const BlogUrlPage(),
                    ));
                  },
                ),
                SettingsTile(
                  title: '博客管理网址',
                  subtitle: state.blogAdminUrl ?? '请单击输入',
                  onPressed: (context) {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const BlogAdminUrlPage(),
                    ));
                  },
                ),
              ],
            ),
            SettingsSection(
              title: '留言板',
              tiles: [
                SettingsTile(
                  title: '评论排序',
                  subtitle: state.commentDescending ? '倒序' : '正序',
                  onPressed: (context) {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const CommentOrderPage(),
                    ));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
