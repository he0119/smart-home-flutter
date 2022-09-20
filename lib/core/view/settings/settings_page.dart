import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:smarthome/app/settings/settings_controller.dart';
import 'package:smarthome/blog/blog.dart';
import 'package:smarthome/board/board.dart';
import 'package:smarthome/core/model/models.dart';
import 'package:smarthome/core/view/settings/admin_url_page.dart';
import 'package:smarthome/core/view/settings/api_url_page.dart';
import 'package:smarthome/core/view/settings/default_page.dart';
import 'package:smarthome/core/view/settings/mipush_settings_tile.dart';
import 'package:smarthome/core/view/settings/session_page.dart';
import 'package:smarthome/core/view/settings/theme_mode.dart';
import 'package:smarthome/iot/iot.dart';
import 'package:smarthome/user/bloc/bloc/session_bloc.dart';
import 'package:smarthome/user/repository/user_repository.dart';
import 'package:smarthome/utils/theme_mode_extension.dart';
import 'package:smarthome/widgets/settings/settings.dart';

class SettingsPage extends Page {
  const SettingsPage()
      : super(
          key: const ValueKey('settings'),
          name: '/settings',
        );

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
      body: Consumer<SettingsController>(
        builder: (context, settings, child) => SettingsList(
          sections: [
            SettingsSection(
              title: '通用',
              tiles: [
                SettingsTile(
                  title: '主题',
                  subtitle: settings.themeMode.toReadable(),
                  onPressed: (context) {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const ThemeModePage(),
                    ));
                  },
                ),
                SettingsTile(
                  title: '服务器网址',
                  subtitle: settings.apiUrl ?? settings.appConfig.defaultApiUrl,
                  onPressed: (context) {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const ApiUrlPage(),
                    ));
                  },
                ),
                SettingsTile(
                  title: '管理网址',
                  subtitle: settings.adminUrl,
                  onPressed: (context) {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const AdminUrlPage(),
                    ));
                  },
                ),
                SettingsTile(
                  title: '默认主页',
                  subtitle: settings.defaultPage.name,
                  onPressed: (context) {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const DefaultPage(),
                    ));
                  },
                ),
                if (!kIsWeb && Platform.isAndroid) const MiPushSettingsTile(),
                SettingsTile(
                  title: '登陆设备管理',
                  onPressed: (context) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => BlocProvider(
                          create: (context) =>
                              SessionBloc(context.read<UserRepository>())
                                ..add(SessionFetched()),
                          child: const SessionPage(),
                        ),
                      ),
                    );
                  },
                )
              ],
            ),
            SettingsSection(
              title: '物联网',
              tiles: [
                SettingsTile(
                  title: '刷新间隔',
                  subtitle: settings.refreshInterval.toString(),
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
                  subtitle: settings.blogUrl,
                  onPressed: (context) {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const BlogUrlPage(),
                    ));
                  },
                ),
                SettingsTile(
                  title: '博客管理网址',
                  subtitle: settings.blogAdminUrl ?? '请单击输入',
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
      ),
    );
  }
}
