import 'package:material_ui/material_ui.dart';
import 'package:smarthome/core/router/router_extensions.dart';
import 'package:smarthome/storage/model/storage.dart';
import 'package:smarthome/utils/date_format_extension.dart';
import 'package:smarthome/widgets/list_rows.dart';
import 'package:flutter/widget_previews.dart';
import 'package:smarthome/widgets/preview_frame.dart';

/// 物品列表里的一行：名称 + 备注（没有就显示位置）+ 右侧相对时间。
class ItemRow extends StatelessWidget {
  final Item item;
  final ItemType type;

  /// 是否保留副标题行。
  ///
  /// 首页只要名称和时间，关掉副标题，每行统一 56；
  /// 分类完整列表开着，每行都留这一行（有备注放备注，没备注放位置），统一 72。
  /// 同一个列表里不要一半有副标题一半没有，行高会忽高忽低。
  final bool showSupporting;

  const ItemRow({
    super.key,
    required this.item,
    required this.type,
    this.showSupporting = true,
  });

  @override
  Widget build(BuildContext context) {
    final time = switch (type) {
      ItemType.expired ||
      ItemType.nearExpired => item.expiredAt?.differenceFromNowStr() ?? '',
      ItemType.recentlyCreated => item.createdAt?.differenceFromNowStr() ?? '',
      ItemType.recentlyEdited => item.editedAt?.differenceFromNowStr() ?? '',
      ItemType.all => '',
    };
    // 副标题优先放备注，没有备注再退到位置名；两者都没有就留空，
    // 但仍然占住这一行，保证同一个列表里每行高度一致
    final description = item.description;
    final storageName = item.storage?.name;
    final supporting = !showSupporting
        ? null
        : ((description != null && description.isNotEmpty)
              ? description
              : (storageName ?? ''));

    return ContentRow(
      icon: Icons.inventory_2_outlined,
      title: Text(item.name),
      supporting: supporting == null
          ? null
          : Text(supporting, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: time.isEmpty
          ? null
          : Text(
              time,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
      onTap: () {
        context.goItemDetail(item.id);
      },
    );
  }
}

/// 开发时在 IDE 里直接看效果，不依赖后端数据。
@Preview(name: 'ItemRow', group: previewGroupStorage, size: Size(400, 240))
Widget itemRowPreview() {
  const cabinet = Storage(id: 'cabinet', name: '阳台储物柜');
  final now = DateTime.now();
  return PreviewFrame(
    width: 400,
    padding: EdgeInsets.zero,
    child: Column(
      children: <Widget>[
        // 有备注：副标题显示备注，右侧是录入距今多久
        ItemRow(
          item: Item(
            id: 'toolbox',
            name: '电动螺丝刀',
            description: '小米，2024 年买的',
            createdAt: now.subtract(const Duration(days: 3)),
          ),
          type: ItemType.recentlyCreated,
        ),
        const ContentDivider(),
        // 没备注：副标题退回位置名
        ItemRow(
          item: Item(
            id: 'battery',
            name: '备用电池',
            storage: cabinet,
            createdAt: now.subtract(const Duration(hours: 5)),
          ),
          type: ItemType.recentlyCreated,
        ),
        const ContentDivider(),
        // 首页样式：关掉副标题，行高压到 56
        ItemRow(
          item: Item(
            id: 'umbrella',
            name: '雨伞',
            createdAt: now.subtract(const Duration(days: 30)),
          ),
          type: ItemType.recentlyCreated,
          showSupporting: false,
        ),
      ],
    ),
  );
}
