import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/widgets/home_page.dart';
import 'package:smarthome/widgets/settings/settings.dart';

class DefaultPage extends ConsumerWidget {
  const DefaultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return MySliverScaffold(
      title: const Text('默认主页'),
      sliver: SettingsList(
        sections: [
          SettingsSection(
            tiles: [
              SettingsTile(
                title: AppTab.storage.name,
                trailing: SelectionCheck(
                  selected: AppTab.storage == settings.defaultPage,
                ),
                onPressed: (context) {
                  ref
                      .read(settingsProvider.notifier)
                      .updateDefaultPage(AppTab.storage);
                },
              ),
              SettingsTile(
                title: AppTab.blog.name,
                trailing: SelectionCheck(
                  selected: AppTab.blog == settings.defaultPage,
                ),
                onPressed: (context) {
                  ref
                      .read(settingsProvider.notifier)
                      .updateDefaultPage(AppTab.blog);
                },
              ),
              SettingsTile(
                title: AppTab.board.name,
                trailing: SelectionCheck(
                  selected: AppTab.board == settings.defaultPage,
                ),
                onPressed: (context) {
                  ref
                      .read(settingsProvider.notifier)
                      .updateDefaultPage(AppTab.board);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
