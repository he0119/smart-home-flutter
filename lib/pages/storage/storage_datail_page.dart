import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/blocs/storage/storage_detail/storage_detail_bloc.dart';
import 'package:smart_home/blocs/storage/storage_form/storage_form_bloc.dart';
import 'package:smart_home/models/detail_page_menu.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/pages/storage/item_datail_page.dart';
import 'package:smart_home/pages/storage/search_page.dart';
import 'package:smart_home/widgets/show_snack_bar.dart';
import 'package:smart_home/widgets/storage_form.dart';
import 'package:smart_home/widgets/storage_item_list.dart';

class StorageDetailPage extends StatelessWidget {
  final String storageId;

  const StorageDetailPage({Key key, this.storageId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StorageDetailBloc(
        snackBarBloc: BlocProvider.of<SnackBarBloc>(context),
      )..add(
          storageId != null
              ? StorageDetailChanged(id: storageId)
              : StorageDetailRoot(),
        ),
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
            if (state is StorageEditInitial) {
              BlocProvider.of<StorageDetailBloc>(context).add(
                StorageDetailChanged(id: state.storage.id),
              );
              return false;
            }
            if (state is StorageAddInitial) {
              BlocProvider.of<StorageDetailBloc>(context).add(
                StorageDetailChanged(id: state.parentId),
              );
              return false;
            }
            if (state is StorageDetailSuccess && state.storage.parent != null) {
              BlocProvider.of<StorageDetailBloc>(context).add(
                StorageDetailChanged(id: state.storage.parent.id),
              );
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
              child: BlocListener<SnackBarBloc, SnackBarState>(
                  condition: (previous, current) {
                    if (current is SnackBarSuccess &&
                        current.position == SnackBarPosition.storage) {
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
            floatingActionButton: _buildFloatingActionButton(context, state),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context, StorageDetailState state) {
    if (state is StorageDetailInProgress) {
      return AppBar(
        title: Text('加载中'),
      );
    }
    if (state is StorageDetailError) {
      return AppBar(
        title: Text('错误'),
      );
    }
    if (state is StorageDetailRootSuccess) {
      return AppBar(
        title: Text('家'),
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
        ],
      );
    }
    if (state is StorageDetailSuccess) {
      return AppBar(
        title: Text(state.storage.name),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              BlocProvider.of<StorageDetailBloc>(context).add(
                StorageAddStarted(parentId: state.storage.id),
              );
            },
          ),
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
                BlocProvider.of<StorageDetailBloc>(context)
                    .add(StorageEditStarted(id: state.storage.id));
              }
              if (value == Menu.delete) {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text('删除 ${state.storage.name}'),
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
                          BlocProvider.of<StorageDetailBloc>(context).add(
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
      );
    }
    if (state is StorageEditInitial) {
      return AppBar(
        title: Text('编辑 ${state.storage.name}'),
      );
    }
    if (state is StorageAddInitial) {
      return AppBar(
        title: Text('添加物品'),
      );
    }
    return null;
  }

  Widget _buildBody(BuildContext context, StorageDetailState state) {
    if (state is StorageDetailInProgress) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    if (state is StorageDetailError) {
      return Center(
        child: Text(state.message),
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
    if (state is StorageEditInitial) {
      return BlocProvider(
        create: (context) => StorageFormBloc(
          storageDetailBloc: BlocProvider.of<StorageDetailBloc>(context),
        ),
        child: StorageForm(
          isEditing: true,
          storage: state.storage,
        ),
      );
    }
    if (state is StorageAddInitial) {
      return BlocProvider(
        create: (context) => StorageFormBloc(
          storageDetailBloc: BlocProvider.of<StorageDetailBloc>(context),
        ),
        child: StorageForm(
          isEditing: false,
          storageId: state.parentId,
        ),
      );
    }
    return Container();
  }

  Widget _buildFloatingActionButton(
      BuildContext context, StorageDetailState state) {
    if (state is StorageDetailSuccess) {
      return FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          String storageId = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ItemDetailPage(
                isAdding: true,
                storageId: state.storage.id,
              ),
            ),
          );
          if (storageId != null) {
            BlocProvider.of<StorageDetailBloc>(context)
                .add(StorageDetailRefreshed(id: storageId));
          }
        },
      );
    }
    return null;
  }
}
