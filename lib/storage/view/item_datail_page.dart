import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthome/routers/delegate.dart';
import 'package:smarthome/storage/model/models.dart';
import 'package:smarthome/storage/storage.dart';
import 'package:smarthome/storage/view/consumable_edit_page.dart';
import 'package:smarthome/storage/view/item_edit_page.dart';
import 'package:smarthome/storage/view/picture_add_page.dart';
import 'package:smarthome/storage/view/widgets/search_icon_button.dart';
import 'package:smarthome/utils/date_format_extension.dart';
import 'package:smarthome/utils/show_snack_bar.dart';
import 'package:smarthome/widgets/center_loading_indicator.dart';
import 'package:smarthome/widgets/error_message_button.dart';

class ItemDetailPage extends Page {
  final String itemId;

  ItemDetailPage({
    required this.itemId,
  }) : super(
          key: UniqueKey(),
          name: '/item/$itemId',
        );

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider<ItemDetailBloc>(
            create: (context) => ItemDetailBloc(
              storageRepository: context.read<StorageRepository>(),
            )..add(ItemDetailStarted(
                id: itemId,
              )),
          ),
          BlocProvider<ItemEditBloc>(
            create: (context) => ItemEditBloc(
              storageRepository: context.read<StorageRepository>(),
            ),
          ),
        ],
        child: ItemDetailScreen(
          itemId: itemId,
        ),
      ),
    );
  }
}

class ItemDetailScreen extends StatelessWidget {
  final String itemId;

  const ItemDetailScreen({
    Key? key,
    required this.itemId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ItemDetailBloc, ItemDetailState>(
      builder: (context, state) {
        return Scaffold(
          appBar: _buildAppBar(context, state),
          body: RefreshIndicator(
            onRefresh: () async {
              context.read<ItemDetailBloc>().add(
                    ItemDetailRefreshed(),
                  );
            },
            child: BlocListener<ItemEditBloc, ItemEditState>(
              listener: (context, state) {
                if (state is ItemDeleteSuccess) {
                  showInfoSnackBar('物品 ${state.item.name} 删除成功');
                  Navigator.of(context).pop();
                }
                if (state is ItemEditFailure) {
                  showErrorSnackBar(state.message);
                }
              },
              child: _buildBody(context, state),
            ),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context, ItemDetailState state) {
    return AppBar(
      title: Text(state.item.name),
      actions: <Widget>[
        const SearchIconButton(),
        PopupMenuButton<ItemDetailMenu>(
          onSelected: (value) async {
            final itemDetailBloc = context.read<ItemDetailBloc>();
            final navigator = Navigator.of(context);
            final myRouterDelegate = MyRouterDelegate.of(context);

            if (value == ItemDetailMenu.edit) {
              final r = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider<ItemEditBloc>(
                    create: (_) => ItemEditBloc(
                      storageRepository: context.read<StorageRepository>(),
                    ),
                    child: ItemEditPage(
                      isEditing: true,
                      item: state.item,
                    ),
                  ),
                ),
              );
              if (r == true) {
                itemDetailBloc.add(ItemDetailStarted(id: state.item.id));
              }
            }
            if (value == ItemDetailMenu.consumable) {
              await navigator.push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider<ItemEditBloc>(
                    create: (_) => ItemEditBloc(
                      storageRepository: context.read<StorageRepository>(),
                    ),
                    child: ConsumableEditPage(
                      item: state.item,
                    ),
                  ),
                ),
              );
              itemDetailBloc.add(ItemDetailStarted(id: state.item.id));
            }
            if (value == ItemDetailMenu.addPicture) {
              myRouterDelegate.push(PictureAddPage(itemId: state.item.id));
            }
            if (value == ItemDetailMenu.delete) {
              await showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('删除 ${state.item.name}'),
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
                        context.read<ItemEditBloc>().add(
                              ItemDeleted(item: state.item),
                            );
                        Navigator.of(context).pop();
                      },
                      child: const Text('是'),
                    ),
                  ],
                ),
              );
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
        )
      ],
    );
  }

  Widget _buildBody(BuildContext context, ItemDetailState state) {
    if (state.status == ItemDetailStatus.failure) {
      return ErrorMessageButton(
        onPressed: () {
          context.read<ItemDetailBloc>().add(
                ItemDetailStarted(id: itemId),
              );
        },
        message: state.error,
      );
    }
    if (state.status == ItemDetailStatus.success) {
      return _ItemDetailList(item: state.item);
    }
    return const CenterLoadingIndicator();
  }
}

class _ItemDetailList extends StatelessWidget {
  final Item item;

  const _ItemDetailList({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        ListTile(
          title: const Text('数量'),
          subtitle: SelectableText(item.number.toString()),
        ),
        if (item.description != null && item.description!.isNotEmpty)
          ListTile(
            title: const Text('备注'),
            subtitle: SelectableText(item.description!),
          ),
        if (item.storage != null)
          ListTile(
            title: const Text('属于'),
            subtitle: SelectableText(
              item.storage!.name,
              onTap: () {
                MyRouterDelegate.of(context)
                    .push(StorageDetailPage(storageId: item.storage!.id));
              },
              style: const TextStyle(
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        if (item.price != null)
          ListTile(
            title: const Text('价格'),
            subtitle: SelectableText(item.price.toString()),
          ),
        if (item.expiredAt != null)
          ListTile(
            title: const Text('有效期至'),
            subtitle: SelectableText(item.expiredAt?.toLocalStr() ?? ''),
          ),
        if (item.consumables!.isNotEmpty)
          ListTile(
            title: const Text('耗材'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: item.consumables!
                  .map(
                    (item) => SelectableText(
                      item.name,
                      onTap: () {
                        MyRouterDelegate.of(context)
                            .push(ItemDetailPage(itemId: item.id));
                      },
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        if (item.editedBy != null)
          ListTile(
            title: const Text('修改人'),
            subtitle: SelectableText(item.editedBy!.username),
          ),
        ListTile(
          title: const Text('修改时间'),
          subtitle: SelectableText(item.editedAt?.toLocalStr() ?? ''),
        ),
        if (item.createdBy != null)
          ListTile(
            title: const Text('录入人'),
            subtitle: SelectableText(item.createdBy!.username),
          ),
        ListTile(
          title: const Text('录入时间'),
          subtitle: SelectableText(item.createdAt?.toLocalStr() ?? ''),
        ),
        if (item.pictures!.isNotEmpty)
          for (Picture picture in item.pictures!)
            ListTile(
              title: picture.description.isNotEmpty
                  ? Text('图片（${picture.description}）')
                  : const Text('图片（未命名）'),
              subtitle: const Text('单击查看'),
              onTap: () {
                MyRouterDelegate.of(context)
                    .push(PicturePage(pictureId: picture.id));
              },
            )
      ],
    );
  }
}
