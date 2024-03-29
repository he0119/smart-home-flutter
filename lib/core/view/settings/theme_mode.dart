import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smarthome/app/settings/settings_controller.dart';
import 'package:smarthome/utils/theme_mode_extension.dart';
import 'package:smarthome/widgets/home_page.dart';
import 'package:smarthome/widgets/settings/settings.dart';

class ThemeModePage extends StatelessWidget {
  const ThemeModePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsController>(
      builder: (context, settings, child) => MySliverScaffold(
        title: const Text('主题'),
        sliver: SettingsList(
          sections: [
            SettingsSection(
              tiles: [
                SettingsTile(
                  title: ThemeMode.system.toReadable(),
                  trailing: trailingWidget(
                      context, ThemeMode.system, settings.themeMode),
                  onPressed: (context) {
                    context
                        .read<SettingsController>()
                        .updateThemeMode(ThemeMode.system);
                  },
                ),
                SettingsTile(
                  title: ThemeMode.light.toReadable(),
                  trailing: trailingWidget(
                      context, ThemeMode.light, settings.themeMode),
                  onPressed: (context) {
                    context
                        .read<SettingsController>()
                        .updateThemeMode(ThemeMode.light);
                  },
                ),
                SettingsTile(
                  title: ThemeMode.dark.toReadable(),
                  trailing: trailingWidget(
                      context, ThemeMode.dark, settings.themeMode),
                  onPressed: (context) {
                    context
                        .read<SettingsController>()
                        .updateThemeMode(ThemeMode.dark);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget trailingWidget(
      BuildContext context, ThemeMode appTab, ThemeMode current) {
    return (appTab == current)
        ? Icon(Icons.check, color: Theme.of(context).colorScheme.secondary)
        : const Icon(null);
  }
}
