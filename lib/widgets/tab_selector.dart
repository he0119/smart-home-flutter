import 'package:flutter/material.dart';
import 'package:smarthome/core/core.dart';

class TabSelector extends StatelessWidget {
  final AppTab activeTab;
  final Function(AppTab) onTabSelected;

  const TabSelector({
    Key? key,
    required this.activeTab,
    required this.onTabSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: AppTab.values.indexOf(activeTab),
      onTap: (index) => onTabSelected(AppTab.values[index]),
      items: AppTab.values
          .map(
            (tab) => BottomNavigationBarItem(
              icon: tab.icon,
              label: tab.name,
            ),
          )
          .toList(),
    );
  }
}
