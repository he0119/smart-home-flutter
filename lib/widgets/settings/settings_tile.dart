import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Function(BuildContext context)? onPressed;
  final Widget? trailing;

  const SettingsTile({
    Key? key,
    required this.title,
    this.subtitle,
    this.onPressed,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing,
      onTap: onPressed != null ? () => onPressed!(context) : null,
    );
  }
}
