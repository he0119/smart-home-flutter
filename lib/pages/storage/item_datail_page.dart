import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smart_home/blocs/storage/blocs.dart';
import 'package:smart_home/models/detail_page_menu.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/pages/error_page.dart';
import 'package:smart_home/pages/loading_page.dart';
import 'package:smart_home/pages/storage/item_edit_page.dart';
import 'package:smart_home/pages/storage/storage_datail_page.dart';
import 'package:smart_home/pages/storage/widgets/search_icon_button.dart';
import 'package:smart_home/repositories/storage_repository.dart';
import 'package:smart_home/utils/date_format_extension.dart';
import 'package:smart_home/widgets/show_snack_bar.dart';

class ItemDetailPage extends StatelessWidget {
  final String itemId;

  const ItemDetailPage({
    Key key,
    @required this.itemId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ItemDetailBloc>(
          create: (context) => ItemDetailBloc(
            storageRepository:
                RepositoryProvider.of<StorageRepository>(context),
          )..add(ItemDetailChanged(itemId: itemId)),
        ),
        BlocProvider<ItemEditBloc>(
          create: (context) => ItemEditBloc(
            storageRepository:
                RepositoryProvider.of<StorageRepository>(context),
          ),
        ),
      ],
      child: _ItemDetailPage(itemId: itemId),
    );
  }
}

class _ItemDetailPage extends StatelessWidget {
  final String itemId;

  const _ItemDetailPage({
    Key key,
    @required this.itemId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ItemDetailBloc, ItemDetailState>(
      builder: (context, state) {
        return Scaffold(
          appBar: _buildAppBar(context, state),
          body: RefreshIndicator(
            onRefresh: () async {
              BlocProvider.of<ItemDetailBloc>(context).add(
                ItemDetailRefreshed(itemId: itemId),
              );
            },
            child: BlocListener<ItemEditBloc, ItemEditState>(
              listener: (context, state) {
                if (state is ItemDeleteSuccess) {
                  showInfoSnackBar('物品 ${state.item.name} 删除成功');
                  Navigator.pop(context);
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
    if (state is ItemDetailSuccess) {
      return AppBar(
        title: Text(state.item.name),
        actions: <Widget>[
          SearchIconButton(),
          PopupMenuButton<Menu>(
            onSelected: (value) async {
              if (value == Menu.edit) {
                await Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => BlocProvider<ItemEditBloc>(
                    create: (_) => ItemEditBloc(
                      storageRepository:
                          RepositoryProvider.of<StorageRepository>(context),
                    ),
                    child: ItemEditPage(
                      isEditing: true,
                      item: state.item,
                    ),
                  ),
                ));
                BlocProvider.of<ItemDetailBloc>(context)
                    .add(ItemDetailChanged(itemId: state.item.id));
              }
              if (value == Menu.delete) {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text('删除 ${state.item.name}'),
                    content: Text('你确认要删除该物品么？'),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('否'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      FlatButton(
                        child: Text('是'),
                        onPressed: () {
                          BlocProvider.of<ItemEditBloc>(context).add(
                            ItemDeleted(item: state.item),
                          );
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                );
              }
            },
            itemBuilder: (context) => [
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
        ],
      );
    }
    return AppBar();
  }

  Widget _buildBody(BuildContext context, ItemDetailState state) {
    if (state is ItemDetailFailure) {
      return ErrorPage(
        onPressed: () {
          BlocProvider.of<ItemDetailBloc>(context).add(
            ItemDetailChanged(itemId: state.itemId),
          );
        },
        message: state.message,
      );
    }
    if (state is ItemDetailSuccess) {
      return _ItemDetailList(item: state.item);
    }
    return LoadingPage();
  }
}

class _ItemDetailList extends StatelessWidget {
  final Item item;

  const _ItemDetailList({Key key, @required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        ListTile(
          title: Text('数量'),
          trailing: SelectableText(item.number.toString()),
        ),
        ListTile(
          title: Text('备注'),
          trailing: SelectableText(item.description ?? ''),
        ),
        ListTile(
          title: Text('属于'),
          trailing: SelectableText(
            item.storage.name,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      StorageDetailPage(storageId: item.storage.id),
                ),
              );
            },
            style: TextStyle(
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        ListTile(
          title: Text('价格'),
          trailing: SelectableText(item.price?.toString() ?? ''),
        ),
        ListTile(
          title: Text('有效期至'),
          trailing: SelectableText(item.expiredAt?.toLocalStr() ?? ''),
        ),
        ListTile(
          title: Text('修改人'),
          trailing: SelectableText(item.editedBy.username),
        ),
        ListTile(
          title: Text('修改时间'),
          trailing: SelectableText(item.editedAt?.toLocalStr() ?? ''),
        ),
        ListTile(
          title: Text('录入人'),
          trailing: SelectableText(item.createdBy.username),
        ),
        ListTile(
          title: Text('录入时间'),
          trailing: SelectableText(item.createdAt?.toLocalStr() ?? ''),
        ),
      ],
    );
  }
}
