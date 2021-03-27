import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:smarthome/blog/view/blog_admin_url_page.dart';
import 'package:smarthome/blog/view/blog_url_page.dart';
import 'package:smarthome/core/core.dart';

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
  const BlogSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('博客'),
      ),
      body: BlocBuilder<AppPreferencesBloc, AppPreferencesState>(
        builder: (context, state) => SettingsList(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          contentPadding: EdgeInsets.symmetric(vertical: 20),
          sections: [
            SettingsSection(
              title: '网址',
              tiles: [
                SettingsTile(
                  title: '博客网址',
                  subtitle: state.blogUrl,
                  onPressed: (context) {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => BlogUrlPage(),
                    ));
                  },
                ),
                SettingsTile(
                  title: '博客管理网址',
                  subtitle: state.blogAdminUrl ?? '请单击输入',
                  onPressed: (context) {
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
