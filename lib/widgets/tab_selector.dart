import 'package:flutter/cupertino.dart';
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
      currentIndex: AppTab.values.indexOf(activeTab),
      onTap: (index) => onTabSelected(AppTab.values[index]),
      items: AppTab.values.map((tab) => navigationBarItem(tab)).toList(),
    );
  }

  static BottomNavigationBarItem navigationBarItem(AppTab appTab) {
    if (appTab == AppTab.iot) {
      return BottomNavigationBarItem(
          icon: Icon(Icons.cloud), title: Text('IOT'));
    }
    if (appTab == AppTab.storage) {
      return BottomNavigationBarItem(
          icon: Icon(Icons.storage), title: Text('物品'));
    }
    return BottomNavigationBarItem(icon: Icon(Icons.chat), title: Text('留言板'));
  }
}
