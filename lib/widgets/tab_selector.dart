import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smarthome/core/core.dart';

class TabSelector extends StatelessWidget {
  final AppTab activeTab;

  const TabSelector({
    super.key,
    required this.activeTab,
  });

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
      selectedIndex: AppTab.values.indexOf(activeTab),
      onDestinationSelected: (index) {
        context.go(AppTab.values[index].path);
      },
    );
  }
}
