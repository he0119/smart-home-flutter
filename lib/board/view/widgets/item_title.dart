import 'package:flutter/material.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/user/user.dart';
import 'package:smarthome/utils/date_format_extension.dart';
import 'package:smarthome/widgets/avatar.dart';

class ItemTitle extends StatelessWidget {
  final User user;
  final DateTime createdAt;
  final DateTime editedAt;
  final Function(Menu)? onSelected;

  const ItemTitle({
    Key? key,
    required this.user,
    required this.createdAt,
    required this.editedAt,
    this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: MyCircleAvatar(avatarUrl: user.avatarUrl),
      title: Text(user.username),
      subtitle: isSameDateTime(createdAt, editedAt)
          ? Text(createdAt.toLocalStr())
          : Text('${createdAt.toLocalStr()} 已编辑'),
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

/// 是否是同一个时间
///
/// 因为服务器上的问题，导致就算是未修改的情况下，也会有一定的误差
bool isSameDateTime(DateTime a, DateTime b) {
  return a.year == b.year &&
      a.month == b.month &&
      a.day == b.day &&
      a.hour == b.hour &&
      a.minute == b.minute &&
      a.second == b.second;
}
