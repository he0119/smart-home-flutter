import 'package:material_ui/material_ui.dart';
import 'package:smarthome/widgets/list_rows.dart';
import 'package:smarthome/widgets/settings/settings_tile.dart';
import 'package:smarthome/widgets/app_preview.dart';
import 'package:smarthome/widgets/preview_frame.dart';

class SettingsSection extends StatelessWidget {
  final String? title;
  final List<Widget> tiles;

  const SettingsSection({super.key, this.title, required this.tiles});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) SectionHeader(title: title!),
        // 直接铺开，不需要套一层不能滚动的 ListView
        ...tiles,
      ],
    );
  }
}

/// 开发时在 IDE 里直接看效果，不依赖后端数据。
@AppPreview(
  name: 'SettingsSection',
  group: previewGroupSettings,
  size: Size(400, 360),
)
Widget settingsSectionPreview() => PreviewFrame(
  width: 400,
  padding: EdgeInsets.zero,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      SettingsSection(
        title: '通用',
        tiles: <Widget>[
          SettingsTile(title: '主题', subtitle: '跟随系统', onPressed: (context) {}),
          SettingsTile(title: '管理地址', onPressed: (context) {}),
        ],
      ),
      SettingsSection(
        title: '博客',
        tiles: <Widget>[SettingsTile(title: '博客地址', onPressed: (context) {})],
      ),
    ],
  ),
);
