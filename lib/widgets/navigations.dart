import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:smarthome/core/model/models.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: AppTab.values
          .map((tab) => NavigationDestination(icon: tab.icon, label: tab.name))
          .toList(),
    );
  }
}

@Preview(name: 'BottomNavBar')
Widget bottomNavBarPreview() => Scaffold(
  bottomNavigationBar: BottomNavBar(
    selectedIndex: 0,
    onDestinationSelected: (index) {},
  ),
);

class SideNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const SideNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: AppTab.values
          .map(
            (tab) => NavigationRailDestination(
              icon: tab.icon,
              label: Text(tab.name),
            ),
          )
          .toList(),
    );
  }
}

@Preview(name: 'SideNavBar')
Widget sideNavBarPreview() => Scaffold(
  body: Row(
    children: [
      SideNavBar(selectedIndex: 0, onDestinationSelected: (index) {}),
      const Expanded(child: Center(child: Text('Content Area'))),
    ],
  ),
);
