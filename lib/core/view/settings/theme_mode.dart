import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/core/providers/settings_provider.dart';
import 'package:smarthome/utils/theme_mode_extension.dart';
import 'package:smarthome/widgets/home_page.dart';
import 'package:smarthome/widgets/settings/settings.dart';

class ThemeModePage extends ConsumerWidget {
  const ThemeModePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return MySliverScaffold(
      title: const Text('主题'),
      sliver: SettingsList(
        sections: [
          SettingsSection(
            tiles: [
              SettingsTile(
                title: ThemeMode.system.toReadable(),
                trailing: trailingWidget(
                  context,
                  ThemeMode.system,
                  settings.themeMode,
                ),
                onPressed: (context) {
                  ref
                      .read(settingsProvider.notifier)
                      .updateThemeMode(ThemeMode.system);
                },
              ),
              SettingsTile(
                title: ThemeMode.light.toReadable(),
                trailing: trailingWidget(
                  context,
                  ThemeMode.light,
                  settings.themeMode,
                ),
                onPressed: (context) {
                  ref
                      .read(settingsProvider.notifier)
                      .updateThemeMode(ThemeMode.light);
                },
              ),
              SettingsTile(
                title: ThemeMode.dark.toReadable(),
                trailing: trailingWidget(
                  context,
                  ThemeMode.dark,
                  settings.themeMode,
                ),
                onPressed: (context) {
                  ref
                      .read(settingsProvider.notifier)
                      .updateThemeMode(ThemeMode.dark);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget trailingWidget(
    BuildContext context,
    ThemeMode appTab,
    ThemeMode current,
  ) {
    return (appTab == current)
        ? Icon(Icons.check, color: Theme.of(context).colorScheme.secondary)
        : const Icon(null);
  }
}
