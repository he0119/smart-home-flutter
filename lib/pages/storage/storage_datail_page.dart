import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/models/detail_page_menu.dart';
import 'package:smart_home/pages/storage/search_page.dart';
import 'package:smart_home/pages/storage/storage_add_edit_page.dart';
import 'package:smart_home/widgets/show_snack_bar.dart';
import 'package:smart_home/widgets/storage_item_list.dart';

class StorageStoragePage extends StatelessWidget {
  final String storageId;

  const StorageStoragePage({Key key, @required this.storageId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StorageBloc, StorageState>(
      condition: (previous, current) {
        if (current is StorageStorageDetailResults &&
            current.storage.id == storageId) {
          return true;
        }
        if (current is StorageStorageError && current.id == storageId) {
          return true;
        }
        return false;
      },
      builder: (context, state) {
        if (state is StorageStorageDetailResults) {
          return Scaffold(
            appBar: AppBar(
              title: Text(state.storage.name),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StorageAddEditStoagePage(
                          isEditing: false,
                          storageId: state.storage.id,
                        ),
                      ),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StorageAddEditStoagePage(
                            isEditing: true,
                            storage: state.storage,
                          ),
                        ),
                      );
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
                                BlocProvider.of<StorageBloc>(context).add(
                                  StorageDeleteStorage(storage: state.storage),
                                );
                                int count = 0;
                                Navigator.popUntil(context, (route) {
                                  return count++ == 2;
                                });
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
            ),
            body: BlocListener<StorageBloc, StorageState>(
              listener: (context, state) {
                if (state is StorageAddItemSuccess &&
                    state.storageId == storageId) {
                  showInfoSnackBar(context, '物品添加成功');
                }
                if (state is StorageItemDeleted &&
                    state.storageId == storageId) {
                  showInfoSnackBar(context, '物品删除成功');
                }
                if (state is StorageItemError && state.storageId == storageId) {
                  showErrorSnackBar(context, '物品删除失败，${state.message}');
                }
                if (state is StorageUpdateStorageSuccess &&
                    state.id == storageId) {
                  showInfoSnackBar(context, '位置修改成功');
                }
                if (state is StorageAddStorageSuccess &&
                    state.parentId == storageId) {
                  showInfoSnackBar(context, '位置添加成功');
                }
                if (state is StorageStorageDeleted &&
                    state.parentId == storageId) {
                  showInfoSnackBar(context, '位置删除成功');
                }
                if (state is StorageStorageError &&
                    state.parentId == storageId) {
                  showErrorSnackBar(context, '位置删除失败，${state.message}');
                }
              },
              child: RefreshIndicator(
                onRefresh: () async {
                  BlocProvider.of<StorageBloc>(context)
                      .add(StorageRefreshStorageDetail(id: storageId));
                },
                child: StorageItemList(
                  items: state.storage.items.toList(),
                  storages: state.storage.children.toList(),
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return StorageAddEditStoagePage(
                        isEditing: false,
                        storageId: storageId,
                      );
                    },
                  ),
                );
              },
            ),
          );
        }
        if (state is StorageStorageError) {
          return Scaffold(
            appBar: AppBar(
              title: Text('错误'),
            ),
            body: Center(
              child: Text(state.message),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text('加载中'),
          ),
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
