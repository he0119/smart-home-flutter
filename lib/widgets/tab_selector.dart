import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smarthome/app/settings/settings_controller.dart';
import 'package:smarthome/core/core.dart';

class TabSelector extends StatelessWidget {
  const TabSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      destinations: AppTab.values
          .map(
            (tab) => NavigationDestination(
              icon: tab.icon,
              label: tab.name,
            ),
          )
          .toList(),
      selectedIndex: _calculateSelectedIndex(context),
      onDestinationSelected: (index) {
        context.go(AppTab.values[index].path);
      },
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    final settingsController = Provider.of<SettingsController>(context);
    final activeTab = switch (location) {
      '/storage' => AppTab.storage,
      '/iot' => AppTab.iot,
      '/blog' => AppTab.blog,
      '/board' => AppTab.board,
      _ => settingsController.defaultPage,
    };

    return AppTab.values.indexOf(activeTab);
  }
}
