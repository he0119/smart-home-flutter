import 'package:material_ui/material_ui.dart';
import 'package:smarthome/core/core.dart';
import 'package:flutter/widget_previews.dart';
import 'package:smarthome/widgets/preview_frame.dart';

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

/// 开发时在 IDE 里直接看效果，不依赖后端数据。
@Preview(name: 'TabSelector', group: previewGroupWidgets, size: Size(400, 120))
Widget tabSelectorPreview() => PreviewFrame(
  width: 400,
  padding: EdgeInsets.zero,
  child: Align(
    alignment: Alignment.bottomCenter,
    child: TabSelector(activeTab: AppTab.storage, onTabSelected: (_) {}),
  ),
);
