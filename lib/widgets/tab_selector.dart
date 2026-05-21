import 'package:flutter/material.dart';
import 'package:smarthome/core/core.dart';

class TabSelector extends StatelessWidget {
  final AppTab activeTab;
  final Function(AppTab) onTabSelected;
  final bool extended;

  const TabSelector({
    super.key,
    required this.activeTab,
    required this.onTabSelected,
    this.extended = false,
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

class RailTabSelector extends StatelessWidget {
  final AppTab activeTab;
  final Function(AppTab) onTabSelected;
  final bool extended;

  const RailTabSelector({
    super.key,
    required this.activeTab,
    required this.onTabSelected,
    this.extended = false,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      extended: extended,
      labelType: extended
          ? NavigationRailLabelType.none
          : NavigationRailLabelType.selected,
      destinations: AppTab.values
          .map(
            (tab) => NavigationRailDestination(
              icon: tab.icon,
              label: Text(tab.name),
            ),
          )
          .toList(),
      selectedIndex: AppTab.values.indexOf(activeTab),
      onDestinationSelected: (index) => onTabSelected(AppTab.values[index]),
    );
  }
}
