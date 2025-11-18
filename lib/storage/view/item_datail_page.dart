import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/routers/delegate.dart';
import 'package:smarthome/storage/model/models.dart';
import 'package:smarthome/storage/providers/item_detail_provider.dart';
import 'package:smarthome/storage/providers/item_edit_provider.dart';
import 'package:smarthome/storage/view/consumable_edit_page.dart';
import 'package:smarthome/storage/view/item_edit_page.dart';
import 'package:smarthome/storage/view/picture_add_page.dart';
import 'package:smarthome/storage/view/picture_page.dart';
import 'package:smarthome/storage/view/storage_datail_page.dart';
import 'package:smarthome/storage/view/widgets/search_icon_button.dart';
import 'package:smarthome/utils/date_format_extension.dart';
import 'package:smarthome/utils/show_snack_bar.dart';
import 'package:smarthome/widgets/center_loading_indicator.dart';
import 'package:smarthome/widgets/error_message_button.dart';
import 'package:smarthome/widgets/home_page.dart';

class ItemDetailPage extends Page {
  final String itemId;

  ItemDetailPage({required this.itemId})
    : super(key: UniqueKey(), name: '/item/$itemId');

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) => ItemDetailScreen(itemId: itemId),
    );
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
                final myRouterDelegate = MyRouterDelegate.of(context);

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
                  myRouterDelegate.push(PictureAddPage(itemId: item.id));
                }
                if (value == ItemDetailMenu.delete) {
                  if (context.mounted) {
                    await showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text('删除 ${item.name}'),
                        content: const Text('你确认要删除该物品么？'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('否'),
                          ),
                          TextButton(
                            onPressed: () {
                              ref
                                  .read(itemEditProvider.notifier)
                                  .deleteItem(item);
                              Navigator.of(context).pop();
                            },
                            child: const Text('是'),
                          ),
                        ],
                      ),
                    );
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
                const PopupMenuItem(
                  value: ItemDetailMenu.delete,
                  child: Text('删除'),
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
          SliverErrorMessageButton(
            onPressed: () {
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
    return SliverList(
      delegate: SliverChildListDelegate(<Widget>[
        ListTile(
          title: const Text('数量'),
          subtitle: Text(item.number.toString()),
        ),
        if (item.description != null && item.description!.isNotEmpty)
          ListTile(title: const Text('备注'), subtitle: Text(item.description!)),
        if (item.storage != null)
          ListTile(
            title: const Text('属于'),
            subtitle: InkWell(
              child: Text(
                item.storage!.name,
                style: const TextStyle(decoration: TextDecoration.underline),
              ),
              onTap: () {
                MyRouterDelegate.of(
                  context,
                ).push(StorageDetailPage(storageId: item.storage!.id));
              },
            ),
          ),
        if (item.price != null)
          ListTile(
            title: const Text('价格'),
            subtitle: Text(item.price.toString()),
          ),
        if (item.expiredAt != null)
          ListTile(
            title: const Text('有效期至'),
            subtitle: Text(item.expiredAt?.toLocalStr() ?? ''),
          ),
        if (item.consumables!.isNotEmpty)
          ListTile(
            title: const Text('耗材'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: item.consumables!
                  .map(
                    (item) => InkWell(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      onTap: () {
                        MyRouterDelegate.of(
                          context,
                        ).push(ItemDetailPage(itemId: item.id));
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
        if (item.editedBy != null)
          ListTile(
            title: const Text('修改人'),
            subtitle: Text(item.editedBy!.username),
          ),
        ListTile(
          title: const Text('修改时间'),
          subtitle: Text(item.editedAt?.toLocalStr() ?? ''),
        ),
        if (item.createdBy != null)
          ListTile(
            title: const Text('录入人'),
            subtitle: Text(item.createdBy!.username),
          ),
        ListTile(
          title: const Text('录入时间'),
          subtitle: Text(item.createdAt?.toLocalStr() ?? ''),
        ),
        if (item.deletedAt != null)
          ListTile(
            title: const Text('删除时间'),
            subtitle: Text(item.deletedAt?.toLocalStr() ?? ''),
          ),
        if (item.pictures!.isNotEmpty)
          for (Picture picture in item.pictures!)
            ListTile(
              title: picture.description.isNotEmpty
                  ? Text('图片（${picture.description}）')
                  : const Text('图片（未命名）'),
              subtitle: const Text('单击查看'),
              onTap: () {
                MyRouterDelegate.of(
                  context,
                ).push(PicturePage(pictureId: picture.id));
              },
            ),
      ]),
    );
  }
}
