import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthome/blog/view/settings/blog_admin_url_page.dart';
import 'package:smarthome/blog/view/settings/blog_url_page.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/widgets/settings/settings.dart';

class BlogSettingsPage extends Page {
  const BlogSettingsPage()
      : super(
          key: const ValueKey('settings/blog'),
          name: '/settings/blog',
        );

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (context) => const BlogSettingsScreen(),
    );
  }
}

class BlogSettingsScreen extends StatelessWidget {
  const BlogSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('博客'),
      ),
      body: BlocBuilder<AppPreferencesBloc, AppPreferencesState>(
        builder: (context, state) => SettingsList(
          sections: [
            SettingsSection(
              title: '网址',
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
          ],
        ),
      ),
    );
  }
}
