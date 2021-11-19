import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smarthome/core/settings/settings_controller.dart';
import 'package:smarthome/iot/view/settings/refresh_interval_page.dart';
import 'package:smarthome/widgets/settings/settings.dart';

class IotSettingsPage extends Page {
  const IotSettingsPage()
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
      body: Consumer<SettingsController>(
        builder: (context, settings, child) => SettingsList(
          sections: [
            SettingsSection(
              title: '网络',
              tiles: [
                SettingsTile(
                  title: '刷新间隔',
                  subtitle: settings.refreshInterval.toString(),
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
