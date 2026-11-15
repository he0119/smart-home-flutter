import 'package:material_ui/material_ui.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/user/user.dart';
import 'package:smarthome/utils/date_format_extension.dart';
import 'package:smarthome/widgets/avatar.dart';
import 'package:flutter/widget_previews.dart';
import 'package:smarthome/widgets/preview_frame.dart';

class ItemTitle extends StatelessWidget {
  final User user;
  final DateTime createdAt;
  final DateTime editedAt;
  final Function(Menu)? onSelected;

  const ItemTitle({
    super.key,
    required this.user,
    required this.createdAt,
    required this.editedAt,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: MyCircleAvatar(avatarUrl: user.avatarUrl),
      title: Text(user.username, maxLines: 1, overflow: .ellipsis),
      subtitle: Text(
        isSameDateTime(createdAt, editedAt)
            ? createdAt.toLocalShortStr()
            : '${createdAt.toLocalShortStr()} 已编辑',
        maxLines: 1,
        overflow: .ellipsis,
      ),
      trailing: (onSelected != null)
          ? PopupMenuButton(
              tooltip: '评论操作',
              onSelected: onSelected,
              itemBuilder: (context) => <PopupMenuItem<Menu>>[
                const PopupMenuItem(value: Menu.edit, child: Text('编辑')),
                const PopupMenuItem(value: Menu.delete, child: Text('删除')),
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
  // 服务器写 editedAt 时通常有几秒误差，留一分钟余量，避免满屏「已编辑」
  return a.difference(b).inMinutes.abs() < 1;
}

/// 开发时在 IDE 里直接看效果，不依赖后端数据。
@Preview(name: 'ItemTitle', group: previewGroupBoard, size: Size(400, 200))
Widget itemTitlePreview() {
  final created = DateTime(2026, 11, 10, 9, 30);
  const author = User(username: '橙子', email: 'chengzi@example.com');
  return PreviewFrame(
    width: 400,
    padding: EdgeInsets.zero,
    child: Column(
      children: <Widget>[
        // 没改过：只显示时间
        ItemTitle(user: author, createdAt: created, editedAt: created),
        // 改过：时间后面带「已编辑」，尾部多一个编辑 / 删除菜单
        ItemTitle(
          user: author,
          createdAt: created,
          editedAt: created.add(const Duration(days: 2)),
          onSelected: (Menu menu) {},
        ),
      ],
    ),
  );
}
