import 'package:material_ui/material_ui.dart';
import 'package:smarthome/core/router/router_extensions.dart';
import 'package:smarthome/storage/model/storage.dart';
import 'package:smarthome/utils/date_format_extension.dart';
import 'package:smarthome/widgets/list_rows.dart';

/// 物品列表里的一行：名称 + 备注（没有就显示位置）+ 右侧相对时间。
class ItemRow extends StatelessWidget {
  final Item item;
  final ItemType type;

  /// 是否显示副标题（备注，没有备注时退到位置名）。
  /// 首页只要名称和时间，副标题会关掉；分类完整列表里才显示。
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
    // 副标题优先放备注，没有备注再退到位置名；时间放在尾部，
    // 这样「最近修改」这类列表里的时间一眼能看到，也不挤掉原来的备注
    final description = item.description;
    final storageName = item.storage?.name;
    final supporting = !showSupporting
        ? null
        : ((description != null && description.isNotEmpty)
              ? description
              : storageName);

    return ContentRow(
      icon: Icons.inventory_2_outlined,
      title: Text(item.name),
      supporting: supporting == null || supporting.isEmpty
          ? null
          : Text(supporting),
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
