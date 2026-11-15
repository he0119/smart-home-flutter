import 'package:material_ui/material_ui.dart';
import 'package:flutter/widget_previews.dart';
import 'package:smarthome/widgets/settings/settings_tile.dart';
import 'package:smarthome/widgets/preview_frame.dart';

/// 单选型设置行的尾部：选中显示勾，未选中留出同样宽度的空位保持对齐。
class SelectionCheck extends StatelessWidget {
  final bool selected;

  const SelectionCheck({super.key, required this.selected});

  @override
  Widget build(BuildContext context) {
    if (!selected) {
      // 占位而不是 Icon(null)，意图更直白
      return const SizedBox(width: 24);
    }
    return Icon(Icons.check, color: Theme.of(context).colorScheme.primary);
  }
}

/// 开发时在 IDE 里直接看效果，不依赖后端数据。
/// 放在单选型设置行里看对齐：选中是勾，未选中是等宽空位。
@Preview(
  name: 'SelectionCheck',
  group: previewGroupSettings,
  size: Size(400, 200),
)
Widget selectionCheckPreview() => PreviewFrame(
  width: 400,
  padding: EdgeInsets.zero,
  child: Column(
    children: <Widget>[
      SettingsTile(
        title: '跟随系统',
        onPressed: (context) {},
        trailing: const SelectionCheck(selected: true),
      ),
      SettingsTile(
        title: '浅色',
        onPressed: (context) {},
        trailing: const SelectionCheck(selected: false),
      ),
    ],
  ),
);
