import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:smarthome/blocs/core/blocs.dart';
import 'package:smarthome/models/app_tab.dart';

class DefaultPage extends StatelessWidget {
  const DefaultPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppPreferencesBloc, AppPreferencesState>(
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: Text('默认主页')),
        body: SettingsList(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          contentPadding: EdgeInsets.symmetric(vertical: 20),
          sections: [
            SettingsSection(tiles: [
              SettingsTile(
                title: AppTab.iot.name,
                trailing: trailingWidget(AppTab.iot, state.defaultPage),
                onPressed: (context) {
                  BlocProvider.of<AppPreferencesBloc>(context)
                      .add(DefaultPageChanged(defaultPage: AppTab.iot));
                },
              ),
              SettingsTile(
                title: AppTab.storage.name,
                trailing: trailingWidget(AppTab.storage, state.defaultPage),
                onPressed: (context) {
                  BlocProvider.of<AppPreferencesBloc>(context)
                      .add(DefaultPageChanged(defaultPage: AppTab.storage));
                },
              ),
              SettingsTile(
                title: AppTab.blog.name,
                trailing: trailingWidget(AppTab.blog, state.defaultPage),
                onPressed: (context) {
                  BlocProvider.of<AppPreferencesBloc>(context)
                      .add(DefaultPageChanged(defaultPage: AppTab.blog));
                },
              ),
              SettingsTile(
                title: AppTab.board.name,
                trailing: trailingWidget(AppTab.board, state.defaultPage),
                onPressed: (context) {
                  BlocProvider.of<AppPreferencesBloc>(context)
                      .add(DefaultPageChanged(defaultPage: AppTab.board));
                },
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget trailingWidget(AppTab appTab, AppTab current) {
    return (appTab == current)
        ? Icon(Icons.check, color: Colors.blue)
        : Icon(null);
  }
}
