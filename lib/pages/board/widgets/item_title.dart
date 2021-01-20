import 'package:flutter/material.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/utils/date_format_extension.dart';
import 'package:smart_home/widgets/gravatar.dart';

class ItemTitle extends StatelessWidget {
  final User user;
  final DateTime editedAt;
  final Function(Menu) onSelected;

  const ItemTitle({
    Key key,
    @required this.user,
    @required this.editedAt,
    this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleGravatar(email: user.email),
      title: Text(user.username),
      subtitle: Text(editedAt.toLocalStr()),
      trailing: (onSelected != null)
          ? PopupMenuButton(
              onSelected: onSelected,
              itemBuilder: (context) => <PopupMenuItem<Menu>>[
                PopupMenuItem(
                  value: Menu.edit,
                  child: Text('编辑'),
                ),
                PopupMenuItem(
                  value: Menu.delete,
                  child: Text('删除'),
                ),
              ],
            )
          : null,
    );
  }
}
