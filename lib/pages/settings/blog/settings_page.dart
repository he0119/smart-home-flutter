import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:smarthome/blocs/core/blocs.dart';
import 'package:smarthome/pages/settings/blog/blog_admin_url_page.dart';
import 'package:smarthome/pages/settings/blog/blog_url_page.dart';

class BlogSettingsPage extends Page {
  BlogSettingsPage()
      : super(key: ValueKey('settings/blog'), name: '/settings/blog');

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (context) => BlogSettingsScreen(),
    );
  }
}

class BlogSettingsScreen extends StatelessWidget {
  const BlogSettingsScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('博客'),
      ),
      body: BlocBuilder<AppPreferencesBloc, AppPreferencesState>(
        builder: (context, state) => SettingsList(
          sections: [
            SettingsSection(
              title: '网址',
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
      ),
    );
  }
}
