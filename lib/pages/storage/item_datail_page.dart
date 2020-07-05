import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/blocs/storage/blocs.dart';
import 'package:smart_home/blocs/storage/item_form/item_form_bloc.dart';
import 'package:smart_home/models/detail_page_menu.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/pages/storage/search_page.dart';
import 'package:smart_home/repositories/storage_repository.dart';
import 'package:smart_home/utils/date_format_extension.dart';
import 'package:smart_home/widgets/item_form.dart';
import 'package:smart_home/widgets/show_snack_bar.dart';

class ItemDetailPage extends StatelessWidget {
  final String itemId;
  final bool isAdding;
  final String storageId;
  final StorageHomeBloc storageHomeBloc;
  final StorageDetailBloc storageDetailBloc;
  final StorageSearchBloc storageSearchBloc;
  final String searchKeyword;

  const ItemDetailPage({
    Key key,
    @required this.isAdding,
    this.itemId,
    this.storageId,
    this.storageHomeBloc,
    this.storageDetailBloc,
    this.storageSearchBloc,
    this.searchKeyword,
  })  : assert(isAdding ? storageId != null : itemId != null),
        assert(
            storageDetailBloc != null ||
                storageHomeBloc != null ||
                storageSearchBloc != null,
            '必须至少提供一个 BLoC'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ItemDetailBloc(
        storageRepository: RepositoryProvider.of<StorageRepository>(context),
        snackBarBloc: BlocProvider.of<SnackBarBloc>(context),
        storageDetailBloc: storageDetailBloc,
        storageHomeBloc: storageHomeBloc,
        storageSearchBloc: storageSearchBloc,
        searchKeyword: searchKeyword,
      )..add(
          isAdding
              ? ItemAddStarted(storageId: storageId)
              : ItemDetailChanged(itemId: itemId),
        ),
      child: _ItemDetailPage(itemId: itemId),
    );
  }
}

class _ItemDetailPage extends StatelessWidget {
  final String itemId;

  const _ItemDetailPage({Key key, @required this.itemId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ItemDetailBloc, ItemDetailState>(
      listener: (context, state) {
        if (state is ItemAddSuccess) {
          Navigator.pop(context);
        }
        if (state is ItemDeleteSuccess) {
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        return WillPopScope(
          onWillPop: () async {
            if (state is ItemEditInitial) {
              BlocProvider.of<ItemDetailBloc>(context).add(
                ItemDetailChanged(itemId: state.item.id),
              );
              return false;
            }
            return true;
          },
          child: Scaffold(
            appBar: _buildAppBar(context, state),
            body: RefreshIndicator(
              onRefresh: () async {
                BlocProvider.of<ItemDetailBloc>(context).add(
                  ItemDetailRefreshed(itemId: itemId),
                );
              },
              child: BlocListener<SnackBarBloc, SnackBarState>(
                  listenWhen: (previous, current) {
                    if (current is SnackBarSuccess &&
                        current.position == SnackBarPosition.item) {
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
                  child: _buildBody(context, state)),
            ),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context, ItemDetailState state) {
    if (state is ItemDetailInProgress) {
      return AppBar(
        title: Text('加载中'),
      );
    }
    if (state is ItemDetailError) {
      return AppBar(
        title: Text('错误'),
      );
    }
    if (state is ItemDetailSuccess) {
      return AppBar(
        title: Text(state.item.name),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SearchPage()),
              );
            },
          ),
          PopupMenuButton<Menu>(
            onSelected: (value) async {
              if (value == Menu.edit) {
                BlocProvider.of<ItemDetailBloc>(context)
                    .add(ItemEditStarted(itemId: itemId));
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
                          BlocProvider.of<ItemDetailBloc>(context).add(
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
    if (state is ItemEditInitial) {
      return AppBar(
        title: Text('编辑 ${state.item.name}'),
      );
    }
    if (state is ItemAddInitial) {
      return AppBar(
        title: Text('添加物品'),
      );
    }
    return null;
  }

  Widget _buildBody(BuildContext context, ItemDetailState state) {
    if (state is ItemDetailInProgress) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    if (state is ItemDetailError) {
      return Center(
        child: Text(state.message),
      );
    }
    if (state is ItemDetailSuccess) {
      return _ItemDetailList(item: state.item);
    }
    if (state is ItemEditInitial) {
      return BlocProvider(
        create: (context) => ItemFormBloc(
          storageRepository: RepositoryProvider.of<StorageRepository>(context),
          itemDetailBloc: BlocProvider.of<ItemDetailBloc>(context),
        ),
        child: ItemForm(
          isEditing: true,
          item: state.item,
        ),
      );
    }
    if (state is ItemAddInitial) {
      return BlocProvider(
        create: (context) => ItemFormBloc(
          storageRepository: RepositoryProvider.of<StorageRepository>(context),
          itemDetailBloc: BlocProvider.of<ItemDetailBloc>(context),
        ),
        child: ItemForm(
          isEditing: false,
          storageId: state.storageId,
        ),
      );
    }
    return Container();
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
          trailing: Text(item.number.toString()),
        ),
        ListTile(
          title: Text('备注'),
          trailing: Text(item.description ?? ''),
        ),
        ListTile(
          title: Text('属于'),
          trailing: Text(item.storage.name),
        ),
        ListTile(
          title: Text('价格'),
          trailing: Text(item.price?.toString() ?? ''),
        ),
        ListTile(
          title: Text('有效期至'),
          trailing: Text(item.expirationDate?.toLocalStr() ?? ''),
        ),
        ListTile(
          title: Text('录入者'),
          trailing: Text(item.editor.username),
        ),
        ListTile(
          title: Text('更新时间'),
          trailing: Text(item.updateDate?.toLocalStr() ?? ''),
        ),
        ListTile(
          title: Text('添加时间'),
          trailing: Text(item.dateAdded?.toLocalStr() ?? ''),
        ),
      ],
    );
  }
}
