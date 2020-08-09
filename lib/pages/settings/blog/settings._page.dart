import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/pages/settings/blog/blog_admin_url_page.dart';
import 'package:smart_home/pages/settings/blog/blog_url_page.dart';

class BlogSettingsPage extends StatelessWidget {
  const BlogSettingsPage({Key key}) : super(key: key);

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
