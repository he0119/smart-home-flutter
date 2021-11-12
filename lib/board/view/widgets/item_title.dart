import 'package:flutter/material.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/user/user.dart';
import 'package:smarthome/utils/date_format_extension.dart';
import 'package:smarthome/widgets/avatar.dart';

class ItemTitle extends StatelessWidget {
  final User? user;
  final DateTime? editedAt;
  final Function(Menu)? onSelected;

  const ItemTitle({
    Key? key,
    required this.user,
    required this.editedAt,
    this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: MyCircleAvatar(avatarUrl: user?.avatarUrl),
      title: Text(user!.username),
      subtitle: Text(editedAt!.toLocalStr()),
      trailing: (onSelected != null)
          ? PopupMenuButton(
              onSelected: onSelected,
              itemBuilder: (context) => <PopupMenuItem<Menu>>[
                const PopupMenuItem(
                  value: Menu.edit,
                  child: Text('编辑'),
                ),
                const PopupMenuItem(
                  value: Menu.delete,
                  child: Text('删除'),
                ),
              ],
            )
          : null,
    );
  }
}
