import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:smarthome/core/bloc/blocs.dart';
import 'package:smarthome/utils/theme_mode_extension.dart';

class ThemeModePage extends StatelessWidget {
  const ThemeModePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppPreferencesBloc, AppPreferencesState>(
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('主题')),
        body: SettingsList(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          sections: [
            SettingsSection(tiles: [
              SettingsTile(
                title: ThemeMode.system.toReadable(),
                trailing:
                    trailingWidget(context, ThemeMode.system, state.themeMode),
                onPressed: (context) {
                  BlocProvider.of<AppPreferencesBloc>(context)
                      .add(const ThemeModeChanged(themeMode: ThemeMode.system));
                },
              ),
              SettingsTile(
                title: ThemeMode.light.toReadable(),
                trailing:
                    trailingWidget(context, ThemeMode.light, state.themeMode),
                onPressed: (context) {
                  BlocProvider.of<AppPreferencesBloc>(context)
                      .add(const ThemeModeChanged(themeMode: ThemeMode.light));
                },
              ),
              SettingsTile(
                title: ThemeMode.dark.toReadable(),
                trailing:
                    trailingWidget(context, ThemeMode.dark, state.themeMode),
                onPressed: (context) {
                  BlocProvider.of<AppPreferencesBloc>(context)
                      .add(const ThemeModeChanged(themeMode: ThemeMode.dark));
                },
              ),
            ]),
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
