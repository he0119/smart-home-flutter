import 'package:material_ui/material_ui.dart';
import 'package:flutter/widget_previews.dart';
import 'package:smarthome/widgets/settings/settings_section.dart';
import 'package:smarthome/widgets/settings/settings_tile.dart';
import 'package:smarthome/widgets/preview_frame.dart';

class SettingsList extends StatelessWidget {
  final List<Widget> sections;

  const SettingsList({super.key, required this.sections});

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        return sections[index];
      }, childCount: sections.length),
    );
  }
}

/// 开发时在 IDE 里直接看效果，不依赖后端数据。
/// 它本身是 sliver，必须放进 CustomScrollView 才有滚动上下文。
@Preview(
  name: 'SettingsList',
  group: previewGroupSettings,
  size: Size(400, 400),
)
Widget settingsListPreview() => PreviewFrame(
  width: 400,
  padding: EdgeInsets.zero,
  child: CustomScrollView(
    slivers: <Widget>[
      SettingsList(
        sections: <Widget>[
          SettingsSection(
            title: '通用',
            tiles: <Widget>[
              SettingsTile(
                title: '主题',
                subtitle: '跟随系统',
                onPressed: (context) {},
              ),
            ],
          ),
          SettingsSection(
            title: '关于',
            tiles: <Widget>[const SettingsTile(title: '版本', subtitle: '1.2.3')],
          ),
        ],
      ),
    ],
  ),
);
