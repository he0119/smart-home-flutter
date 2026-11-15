import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smarthome/core/router/router_extensions.dart';
import 'package:smarthome/storage/model/models.dart';
import 'package:smarthome/storage/providers/item_detail_provider.dart';
import 'package:smarthome/storage/providers/item_edit_provider.dart';
import 'package:smarthome/storage/view/consumable_edit_page.dart';
import 'package:smarthome/storage/view/item_edit_page.dart';

import 'package:smarthome/storage/view/widgets/search_icon_button.dart';
import 'package:smarthome/utils/date_format_extension.dart';
import 'package:smarthome/utils/show_confirm_dialog.dart';
import 'package:smarthome/utils/show_snack_bar.dart';
import 'package:smarthome/widgets/center_loading_indicator.dart';
import 'package:smarthome/widgets/home_page.dart';
import 'package:smarthome/widgets/state_views.dart';
import 'package:smarthome/widgets/list_rows.dart';

class ItemDetailPage extends StatelessWidget {
  final String itemId;

  const ItemDetailPage({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    return ItemDetailScreen(itemId: itemId);
  }
}

class ItemDetailScreen extends ConsumerStatefulWidget {
  final String itemId;

  const ItemDetailScreen({super.key, required this.itemId});

  @override
  ConsumerState<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends ConsumerState<ItemDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(itemDetailProvider(widget.itemId));

    // Listen to item edit state for delete notifications
    ref.listen<ItemEditState>(itemEditProvider, (previous, next) {
      if (next.status == ItemEditStatus.deleteSuccess) {
        showInfoSnackBar('物品 ${next.item?.name ?? ''} 删除成功');
        Navigator.of(context).pop();
      }
      if (next.status == ItemEditStatus.failure) {
        showErrorSnackBar(next.errorMessage);
      }
    });

    return state.when(
      data: (item) => SelectionArea(
        child: MySliverScaffold(
          title: Text(item.name),
          actions: <Widget>[
            const SearchIconButton(),
            PopupMenuButton<ItemDetailMenu>(
              onSelected: (value) async {
                final navigator = Navigator.of(context);

                if (value == ItemDetailMenu.edit) {
                  final r = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ItemEditPage(isEditing: true, item: item),
                    ),
                  );
                  if (r == true) {
                    ref
                        .read(itemDetailProvider(widget.itemId).notifier)
                        .refresh();
                  }
                }
                if (value == ItemDetailMenu.consumable) {
                  await navigator.push(
                    MaterialPageRoute(
                      builder: (_) => ConsumableEditPage(item: item),
                    ),
                  );
                  ref
                      .read(itemDetailProvider(widget.itemId).notifier)
                      .refresh();
                }
                if (value == ItemDetailMenu.addPicture) {
                  if (context.mounted) {
                    context.push('/item/${item.id}/picture/add');
                  }
                }
                if (value == ItemDetailMenu.delete) {
                  if (!context.mounted) {
                    return;
                  }
                  final confirmed = await showConfirmDialog(
                    context,
                    title: '删除 ${item.name}',
                    message: '删除后可以在回收站里找回，确认删除？',
                    confirmLabel: '删除',
                    destructive: true,
                  );
                  if (confirmed) {
                    ref.read(itemEditProvider.notifier).deleteItem(item);
                  }
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: ItemDetailMenu.edit,
                  child: Text('编辑'),
                ),
                const PopupMenuItem(
                  value: ItemDetailMenu.addPicture,
                  child: Text('添加图片'),
                ),
                const PopupMenuItem(
                  value: ItemDetailMenu.consumable,
                  child: Text('耗材编辑'),
                ),
                PopupMenuItem(
                  value: ItemDetailMenu.delete,
                  child: Text(
                    '删除',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ],
          onRefresh: () async {
            ref.read(itemDetailProvider(widget.itemId).notifier).refresh();
          },
          slivers: [_ItemDetailList(item: item)],
        ),
      ),
      loading: () => MySliverScaffold(
        title: const Text('加载中...'),
        slivers: [const SliverCenterLoadingIndicator()],
      ),
      error: (error, stack) => MySliverScaffold(
        title: const Text('错误'),
        onRefresh: () async {
          ref.read(itemDetailProvider(widget.itemId).notifier).refresh();
        },
        slivers: [
          SliverErrorState(
            onRetry: () {
              ref.read(itemDetailProvider(widget.itemId).notifier).refresh();
            },
            message: error.toString(),
          ),
        ],
      ),
    );
  }
}

class _ItemDetailList extends StatelessWidget {
  final Item item;

  const _ItemDetailList({required this.item});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final consumables = item.consumables ?? const <Item>[];
    final pictures = item.pictures ?? const <Picture>[];
    final sectionPadding = const EdgeInsets.fromLTRB(16, 24, 16, 4);

    final basicRows = <Widget>[
      InfoRow(label: '数量', value: Text(item.number.toString())),
      if (item.description != null && item.description!.isNotEmpty)
        InfoRow(label: '备注', value: Text(item.description!)),
      if (item.storage != null)
        InfoRow(
          label: '属于',
          value: Text(item.storage!.name),
          trailing: Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
          onTap: () {
            context.goStorageDetail(item.storage!.id);
          },
        ),
      if (item.price != null)
        InfoRow(label: '价格', value: Text(item.price.toString())),
      if (item.expiredAt != null)
        InfoRow(label: '有效期至', value: Text(item.expiredAt!.toLocalStr())),
    ];

    final recordRows = <Widget>[
      if (item.editedBy != null)
        InfoRow(label: '修改人', value: Text(item.editedBy!.username)),
      InfoRow(label: '修改时间', value: Text(item.editedAt?.toLocalStr() ?? '')),
      if (item.createdBy != null)
        InfoRow(label: '录入人', value: Text(item.createdBy!.username)),
      InfoRow(label: '录入时间', value: Text(item.createdAt?.toLocalStr() ?? '')),
      if (item.deletedAt != null)
        InfoRow(label: '删除时间', value: Text(item.deletedAt!.toLocalStr())),
    ];

    return SliverList(
      delegate: SliverChildListDelegate(<Widget>[
        const SectionHeader(
          title: '基本信息',
          padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
        ),
        ..._withDividers(basicRows),
        if (consumables.isNotEmpty) ...<Widget>[
          SectionHeader(title: '耗材', padding: sectionPadding),
          for (var i = 0; i < consumables.length; i++) ...<Widget>[
            ContentRow(
              icon: Icons.inventory_2_outlined,
              title: Text(consumables[i].name),
              supporting: consumables[i].expiredAt == null
                  ? null
                  : Text(consumables[i].expiredAt!.differenceFromNowStr()),
              onTap: () {
                context.goItemDetail(consumables[i].id);
              },
            ),
            if (i < consumables.length - 1) const ContentDivider(),
          ],
        ],
        SectionHeader(title: '记录', padding: sectionPadding),
        ..._withDividers(recordRows),
        if (pictures.isNotEmpty) ...<Widget>[
          SectionHeader(title: '图片', padding: sectionPadding),
          for (var i = 0; i < pictures.length; i++) ...<Widget>[
            ContentRow(
              icon: Icons.photo_outlined,
              title: Text(
                pictures[i].description.isEmpty
                    ? '未命名图片'
                    : pictures[i].description,
              ),
              onTap: () {
                context.goPictureDetail(pictures[i].id);
              },
            ),
            if (i < pictures.length - 1) const ContentDivider(),
          ],
        ],
        const ListBottomPadding(),
      ]),
    );
  }

  /// 字段行之间加细分隔线，一组信息才看得出是一条一条的
  List<Widget> _withDividers(List<Widget> rows) {
    final children = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      children.add(rows[i]);
      if (i < rows.length - 1) {
        children.add(const ContentDivider(indent: 16));
      }
    }
    return children;
  }
}
