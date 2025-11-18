import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/widgets/home_page.dart';
import 'package:smarthome/widgets/settings/settings.dart';

class CommentOrderPage extends ConsumerWidget {
  const CommentOrderPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return MySliverScaffold(
      title: const Text('评论排序'),
      sliver: SettingsList(
        sections: [
          SettingsSection(
            tiles: [
              SettingsTile(
                title: '正序',
                trailing: trailingWidget(
                  context,
                  false,
                  settings.commentDescending,
                ),
                onPressed: (context) {
                  ref
                      .read(settingsProvider.notifier)
                      .updateCommentDescending(false);
                },
              ),
              SettingsTile(
                title: '倒序',
                trailing: trailingWidget(
                  context,
                  true,
                  settings.commentDescending,
                ),
                onPressed: (context) {
                  ref
                      .read(settingsProvider.notifier)
                      .updateCommentDescending(true);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget trailingWidget(BuildContext context, bool descending, bool current) {
    return (descending == current)
        ? Icon(Icons.check, color: Theme.of(context).colorScheme.secondary)
        : const Icon(null);
  }
}
