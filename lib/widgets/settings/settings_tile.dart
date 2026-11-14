import 'package:material_ui/material_ui.dart';

class SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Function(BuildContext context)? onPressed;
  final Widget? trailing;

  const SettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    this.onPressed,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing:
          trailing ??
          (onPressed == null ? null : const Icon(Icons.chevron_right)),
      onTap: onPressed != null ? () => onPressed!(context) : null,
    );
  }
}
