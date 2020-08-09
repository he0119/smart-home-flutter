import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/blocs.dart';
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
  final StorageHomeBloc storageHomeBloc;
  final StorageDetailBloc storageDetailBloc;
  final StorageSearchBloc storageSearchBloc;
  final String searchKeyword;

  const ItemDetailPage({
    Key key,
    @required this.itemId,
    this.storageHomeBloc,
    this.storageDetailBloc,
    this.storageSearchBloc,
    this.searchKeyword,
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
            snackBarBloc: BlocProvider.of<SnackBarBloc>(context),
            itemDetailBloc: BlocProvider.of<ItemDetailBloc>(context),
            storageHomeBloc: storageHomeBloc,
            storageDetailBloc: storageDetailBloc,
            storageSearchBloc: storageSearchBloc,
            searchKeyword: searchKeyword,
          ),
        ),
      ],
      child: _ItemDetailPage(itemId: itemId),
    );
  }
}

class _ItemDetailPage extends StatelessWidget {
  final String itemId;

  const _ItemDetailPage({Key key, @required this.itemId}) : super(key: key);

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
            child: MultiBlocListener(
              listeners: [
                BlocListener<SnackBarBloc, SnackBarState>(
                  // 仅在物品详情页面显示特定消息提示
                  listenWhen: (previous, current) {
                    if (current is SnackBarSuccess &&
                        current.position == SnackBarPosition.itemDetail) {
                      return true;
                    }
                    return false;
                  },
                  listener: (context, state) {
                    if (state is SnackBarSuccess &&
                        state.type == MessageType.error) {
                      showErrorSnackBar(context, state.message);
                    }
                    if (state is SnackBarSuccess &&
                        state.type == MessageType.info) {
                      showInfoSnackBar(context, state.message);
                    }
                  },
                ),
                BlocListener<ItemEditBloc, ItemEditState>(
                  listener: (context, state) {
                    if (state is ItemDeleteSuccess) {
                      Navigator.pop(context);
                    }
                  },
                )
              ],
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
                List<Storage> listofStorages =
                    await RepositoryProvider.of<StorageRepository>(context)
                        .storages();
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: BlocProvider.of<ItemEditBloc>(context),
                    child: ItemEditPage(
                      isEditing: true,
                      listofStorages: listofStorages,
                      item: state.item,
                    ),
                  ),
                ));
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
          trailing: SelectableText(item.expirationDate?.toLocalStr() ?? ''),
        ),
        ListTile(
          title: Text('录入者'),
          trailing: SelectableText(item.editor.username),
        ),
        ListTile(
          title: Text('更新时间'),
          trailing: SelectableText(item.updateDate?.toLocalStr() ?? ''),
        ),
        ListTile(
          title: Text('添加时间'),
          trailing: SelectableText(item.dateAdded?.toLocalStr() ?? ''),
        ),
      ],
    );
  }
}
