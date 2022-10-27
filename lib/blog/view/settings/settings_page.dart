import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smarthome/app/settings/settings_controller.dart';
import 'package:smarthome/blog/view/settings/blog_admin_url_page.dart';
import 'package:smarthome/blog/view/settings/blog_url_page.dart';
import 'package:smarthome/widgets/home_page.dart';
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
    return MySliverScaffold(
      title: const Text('博客'),
      sliver: Consumer<SettingsController>(
        builder: (context, settings, child) => SettingsList(
          sections: [
            SettingsSection(
              title: '网址',
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
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const BlogAdminUrlPage(),
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
