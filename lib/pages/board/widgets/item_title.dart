import 'package:flutter/material.dart';

import 'package:smart_home/models/detail_page_menu.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/utils/date_format_extension.dart';
import 'package:smart_home/widgets/gravatar.dart';

class ItemTitle extends StatelessWidget {
  final User user;
  final DateTime dateModified;
  final Function(Menu) onSelected;

  const ItemTitle({
    Key key,
    this.user,
    this.dateModified,
    this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleGravatar(email: user.email),
      title: Text(user.username),
      subtitle: Text(dateModified.toLocalStr()),
      trailing: onSelected != null
          ? PopupMenuButton(
              icon: Icon(Icons.expand_more),
              onSelected: onSelected,
              itemBuilder: (context) => <PopupMenuItem<Menu>>[
                PopupMenuItem(
                  value: Menu.edit,
                  child: Text('修改'),
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
