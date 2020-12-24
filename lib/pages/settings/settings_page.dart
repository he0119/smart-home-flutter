import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:smart_home/blocs/core/blocs.dart';
import 'package:smart_home/pages/settings/blog/blog_admin_url_page.dart';
import 'package:smart_home/pages/settings/blog/blog_url_page.dart';
import 'package:smart_home/pages/settings/common/api_url_page.dart';
import 'package:smart_home/pages/settings/common/default_page.dart';
import 'package:smart_home/pages/settings/common/mipush_page.dart';
import 'package:smart_home/pages/settings/iot/refresh_interval_page.dart';
import 'package:smart_home/models/app_tab.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设置'),
      ),
      body: BlocBuilder<PushBloc, PushState>(
        builder: (context, state) {
          String _pushStatus = '未注册';
          if (state is PushInProgress) {
            _pushStatus = '注册中';
          }
          if (state is PushSuccess) {
            _pushStatus = '已注册';
          }
          return BlocBuilder<AppPreferencesBloc, AppPreferencesState>(
            builder: (context, state) => SettingsList(
              sections: [
                SettingsSection(
                  title: '通用',
                  tiles: [
                    SettingsTile(
                      title: '服务器网址',
                      subtitle: state.apiUrl ?? '请单击输入',
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ApiUrlPage(),
                        ));
                      },
                    ),
                    SettingsTile(
                      title: '默认主页',
                      subtitle: state.defaultPage.name,
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => DefaultPage(),
                        ));
                      },
                    ),
                    SettingsTile(
                      title: '小米推送',
                      subtitle: _pushStatus,
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => MiPushPage(),
                        ));
                      },
                    ),
                  ],
                ),
                SettingsSection(
                  title: '物联网',
                  tiles: [
                    SettingsTile(
                      title: '刷新间隔',
                      subtitle: state.refreshInterval.toString() ?? '请单击输入',
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => RefreshIntervalPage(),
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
                      subtitle: state.blogUrl ?? '请单击输入',
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => BlogUrlPage(),
                        ));
                      },
                    ),
                    SettingsTile(
                      title: '博客管理网址',
                      subtitle: state.blogAdminUrl ?? '请单击输入',
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => BlogAdminUrlPage(),
                        ));
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
