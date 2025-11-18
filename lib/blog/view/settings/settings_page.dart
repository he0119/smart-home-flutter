import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/core/router/app_router.dart';
import 'package:smarthome/widgets/home_page.dart';
import 'package:smarthome/widgets/settings/settings.dart';

class BlogSettingsPage extends StatelessWidget {
  const BlogSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const BlogSettingsScreen();
  }
}

class BlogSettingsScreen extends ConsumerWidget {
  const BlogSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return MySliverScaffold(
      title: const Text('博客'),
      sliver: SettingsList(
        sections: [
          SettingsSection(
            title: '网址',
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
        ],
      ),
    );
  }
}
