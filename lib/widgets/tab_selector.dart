import 'package:flutter/material.dart';
import 'package:smarthome/core/core.dart';

class TabSelector extends StatelessWidget {
  final AppTab activeTab;
  final Function(AppTab) onTabSelected;

  const TabSelector({
    super.key,
    required this.activeTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      destinations: AppTab.values
          .map((tab) => NavigationDestination(icon: tab.icon, label: tab.name))
          .toList(),
      selectedIndex: AppTab.values.indexOf(activeTab),
      onDestinationSelected: (index) => onTabSelected(AppTab.values[index]),
    );
  }
}
