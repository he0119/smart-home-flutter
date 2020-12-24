import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:smart_home/blocs/core/blocs.dart';
import 'package:smart_home/pages/settings/iot/refresh_interval_page.dart';

class IotSettingsPage extends StatelessWidget {
  const IotSettingsPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('物联网'),
      ),
      body: BlocBuilder<AppPreferencesBloc, AppPreferencesState>(
        builder: (context, state) => SettingsList(
          sections: [
            SettingsSection(
              title: '网络',
              tiles: [
                SettingsTile(
                  title: '刷新间隔',
                  subtitle: state.refreshInterval.toString() ?? '请单击输入',
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => RefreshIntervalPage(),
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
