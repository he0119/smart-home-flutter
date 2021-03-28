import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/iot/view/settings/refresh_interval_page.dart';

class IotSettingsPage extends Page {
  IotSettingsPage()
      : super(key: const ValueKey('settings/iot'), name: '/settings/iot');

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (context) => const IotSettingsScreen(),
    );
  }
}

class IotSettingsScreen extends StatelessWidget {
  const IotSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('物联网'),
      ),
      body: BlocBuilder<AppPreferencesBloc, AppPreferencesState>(
        builder: (context, state) => SettingsList(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
          sections: [
            SettingsSection(
              title: '网络',
              tiles: [
                SettingsTile(
                  title: '刷新间隔',
                  subtitle: state.refreshInterval.toString(),
                  onPressed: (context) {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const RefreshIntervalPage(),
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
