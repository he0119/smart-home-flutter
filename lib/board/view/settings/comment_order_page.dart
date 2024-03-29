import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smarthome/app/settings/settings_controller.dart';
import 'package:smarthome/widgets/home_page.dart';
import 'package:smarthome/widgets/settings/settings.dart';

class CommentOrderPage extends StatelessWidget {
  const CommentOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsController>(
      builder: (context, settings, child) => MySliverScaffold(
        title: const Text('评论排序'),
        sliver: SettingsList(
          sections: [
            SettingsSection(
              tiles: [
                SettingsTile(
                  title: '正序',
                  trailing: trailingWidget(
                      context, false, settings.commentDescending),
                  onPressed: (context) {
                    context
                        .read<SettingsController>()
                        .updateCommentDescending(false);
                  },
                ),
                SettingsTile(
                  title: '倒序',
                  trailing:
                      trailingWidget(context, true, settings.commentDescending),
                  onPressed: (context) {
                    context
                        .read<SettingsController>()
                        .updateCommentDescending(true);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget trailingWidget(BuildContext context, bool descending, bool current) {
    return (descending == current)
        ? Icon(Icons.check, color: Theme.of(context).colorScheme.secondary)
        : const Icon(null);
  }
}
