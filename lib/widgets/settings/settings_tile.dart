import 'package:material_ui/material_ui.dart';
import 'package:flutter/widget_previews.dart';
import 'package:smarthome/widgets/preview_frame.dart';
import 'package:smarthome/widgets/settings/selection_check.dart';

class SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;

  /// 副标题最多几行：错误信息这类长文本可以传 2
  final int subtitleMaxLines;
  final IconData? leading;
  final Function(BuildContext context)? onPressed;
  final Widget? trailing;

  const SettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    this.subtitleMaxLines = 1,
    this.leading,
    this.onPressed,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading == null
          ? null
          : Icon(
              leading,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      title: Text(title),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              maxLines: subtitleMaxLines,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing:
          trailing ??
          (onPressed == null ? null : const Icon(Icons.chevron_right)),
      onTap: onPressed != null ? () => onPressed!(context) : null,
    );
  }
}

/// 开发时在 IDE 里直接看效果，不依赖后端数据。
@Preview(
  name: 'SettingsTile',
  group: previewGroupSettings,
  size: Size(400, 320),
)
Widget settingsTilePreview() => PreviewFrame(
  width: 400,
  padding: EdgeInsets.zero,
  child: Column(
    children: <Widget>[
      SettingsTile(title: '主题', subtitle: '跟随系统', onPressed: (context) {}),
      SettingsTile(
        title: '管理地址',
        subtitle: 'https://admin.example.com',
        onPressed: (context) {},
      ),
      const SettingsTile(title: '消息推送', leading: Icons.notifications_outlined),
      SettingsTile(
        title: '浅色',
        onPressed: (context) {},
        trailing: const SelectionCheck(selected: true),
      ),
    ],
  ),
);
