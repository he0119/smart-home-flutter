import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/blocs/storage/blocs.dart';
import 'package:smart_home/models/detail_page_menu.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/pages/error_page.dart';
import 'package:smart_home/pages/loading_page.dart';
import 'package:smart_home/pages/storage/item_edit_page.dart';
import 'package:smart_home/pages/storage/storage_edit_page.dart';
import 'package:smart_home/pages/storage/widgets/add_storage_icon_button.dart';
import 'package:smart_home/pages/storage/widgets/search_icon_button.dart';
import 'package:smart_home/repositories/storage_repository.dart';
import 'package:smart_home/pages/storage/widgets/storage_item_list.dart';

class StorageDetailPage extends StatelessWidget {
  final String storageId;

  const StorageDetailPage({Key key, this.storageId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<StorageDetailBloc>(
          create: (context) => StorageDetailBloc(
            storageRepository:
                RepositoryProvider.of<StorageRepository>(context),
            snackBarBloc: BlocProvider.of<SnackBarBloc>(context),
          )..add(
              storageId != null
                  ? StorageDetailChanged(id: storageId)
                  : StorageDetailRoot(),
            ),
        ),
        BlocProvider<StorageEditBloc>(
          create: (context) => StorageEditBloc(
            storageRepository:
                RepositoryProvider.of<StorageRepository>(context),
            storageDetailBloc: BlocProvider.of<StorageDetailBloc>(context),
            snackBarBloc: BlocProvider.of<SnackBarBloc>(context),
          ),
        )
      ],
      child: _StorageDetailPage(storageId: storageId),
    );
  }
}

class _StorageDetailPage extends StatelessWidget {
  final String storageId;

  const _StorageDetailPage({Key key, @required this.storageId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StorageDetailBloc, StorageDetailState>(
      builder: (context, state) {
        return WillPopScope(
          onWillPop: () async {
            if (state is StorageDetailSuccess && state.backImmediately) {
              return true;
            }
            if (state is StorageDetailSuccess && state.storage.parent != null) {
              BlocProvider.of<StorageDetailBloc>(context)
                  .add(StorageDetailChanged(id: state.storage.parent.id));
              return false;
            }
            if (state is StorageDetailSuccess && state.storage.parent == null) {
              BlocProvider.of<StorageDetailBloc>(context)
                  .add(StorageDetailRoot());
              return false;
            }
            return true;
          },
          child: Scaffold(
            appBar: _buildAppBar(context, state),
            body: RefreshIndicator(
              onRefresh: () async {
                if (state is StorageDetailSuccess) {
                  BlocProvider.of<StorageDetailBloc>(context).add(
                    StorageDetailRefreshed(id: state.storage.id),
                  );
                }
                if (state is StorageDetailRootSuccess) {
                  BlocProvider.of<StorageDetailBloc>(context).add(
                    StorageDetailRootRefreshed(),
                  );
                }
              },
              child: _buildBody(context, state),
            ),
            floatingActionButton: _buildFloatingActionButton(context, state),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context, StorageDetailState state) {
    if (state is StorageDetailFailure) {
      return AppBar();
    }
    if (state is StorageDetailRootSuccess) {
      return AppBar(
        title: Text('家'),
        actions: <Widget>[
          AddStorageIconButton(),
          SearchIconButton(),
        ],
      );
    }
    if (state is StorageDetailSuccess) {
      List<Storage> paths = state.ancestors.toList();
      return AppBar(
        title: Text(state.storage.name),
        actions: <Widget>[
          AddStorageIconButton(),
          SearchIconButton(),
          PopupMenuButton<Menu>(
            onSelected: (value) async {
              if (value == Menu.edit) {
                List<Storage> listofStorages =
                    await RepositoryProvider.of<StorageRepository>(context)
                        .storages();
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: BlocProvider.of<StorageEditBloc>(context),
                    child: StorageEditPage(
                      isEditing: true,
                      listofStorages: listofStorages,
                      storage: state.storage,
                    ),
                  ),
                ));
              }
              if (value == Menu.delete) {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text('删除 ${state.storage.name}'),
                    content: Text('你确认要删除该位置么？'),
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
                          BlocProvider.of<StorageEditBloc>(context).add(
                            StorageDeleted(storage: state.storage),
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
        bottom: PathBar(
          child: Container(
            height: 40,
            child: Align(
              alignment: Alignment.centerLeft,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: paths.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  return index == 0
                      ? IconButton(
                          icon: Icon(Icons.home),
                          onPressed: () {
                            BlocProvider.of<StorageDetailBloc>(context)
                                .add(StorageDetailRoot());
                          },
                        )
                      : InkWell(
                          onTap: () {
                            BlocProvider.of<StorageDetailBloc>(context).add(
                                StorageDetailChanged(id: paths[index - 1].id));
                          },
                          child: Container(
                            height: 40,
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                child: Text(
                                  paths[index - 1].name,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                  );
                },
              ),
            ),
          ),
        ),
      );
    }
    return AppBar();
  }

  Widget _buildBody(BuildContext context, StorageDetailState state) {
    if (state is StorageDetailFailure) {
      return ErrorPage(
        onPressed: () {
          if (state.storageId != null) {
            BlocProvider.of<StorageDetailBloc>(context).add(
              StorageDetailChanged(id: state.storageId),
            );
          } else {
            BlocProvider.of<StorageDetailBloc>(context).add(
              StorageDetailRoot(),
            );
          }
        },
        message: state.message,
      );
    }
    if (state is StorageDetailRootSuccess) {
      return StorageItemList(
        storages: state.storages.toList(),
        items: [],
      );
    }
    if (state is StorageDetailSuccess) {
      return StorageItemList(
        items: state.storage.items.toList(),
        storages: state.storage.children.toList(),
      );
    }
    return LoadingPage();
  }

  Widget _buildFloatingActionButton(
      BuildContext context, StorageDetailState state) {
    if (state is StorageDetailSuccess) {
      return FloatingActionButton(
        tooltip: '添加物品',
        child: Icon(Icons.add),
        onPressed: () async {
          List<Storage> listofStorages =
              await RepositoryProvider.of<StorageRepository>(context)
                  .storages();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider<ItemEditBloc>(
                create: (_) => ItemEditBloc(
                  storageRepository:
                      RepositoryProvider.of<StorageRepository>(context),
                  snackBarBloc: BlocProvider.of<SnackBarBloc>(context),
                  storageDetailBloc:
                      BlocProvider.of<StorageDetailBloc>(context),
                ),
                child: ItemEditPage(
                  isEditing: false,
                  listofStorages: listofStorages,
                  storageId: state.storage.id,
                ),
              ),
            ),
          );
        },
      );
    }
    return null;
  }
}

class PathBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget child;

  PathBar({
    Key key,
    @required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }

  @override
  Size get preferredSize => Size.fromHeight(40.0);
}
