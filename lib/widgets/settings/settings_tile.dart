import 'package:material_ui/material_ui.dart';

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
