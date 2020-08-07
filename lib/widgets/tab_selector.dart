import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smart_home/models/models.dart';

class TabSelector extends StatelessWidget {
  final AppTab activeTab;
  final Function(AppTab) onTabSelected;

  TabSelector({
    Key key,
    @required this.activeTab,
    @required this.onTabSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: AppTab.values.indexOf(activeTab),
      onTap: (index) => onTabSelected(AppTab.values[index]),
      items: AppTab.values.map((tab) => navigationBarItem(tab)).toList(),
    );
  }

  static BottomNavigationBarItem navigationBarItem(AppTab appTab) {
    if (appTab == AppTab.iot) {
      return BottomNavigationBarItem(
          icon: Icon(Icons.cloud), title: Text(appTab.name));
    }
    if (appTab == AppTab.storage) {
      return BottomNavigationBarItem(
          icon: Icon(Icons.storage), title: Text(appTab.name));
    }
    if (appTab == AppTab.blog) {
      return BottomNavigationBarItem(
          icon: Icon(Icons.web), title: Text(appTab.name));
    }
    return BottomNavigationBarItem(
        icon: Icon(Icons.chat), title: Text(appTab.name));
  }
}
