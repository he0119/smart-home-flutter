import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/pages/storage/item_add_edit_page.dart';
import 'package:smart_home/pages/storage/storage_add_edit_page.dart';
import 'package:smart_home/widgets/storage_item_list.dart';

enum Menu { edit, delete }

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
                                BlocProvider.of<StorageBloc>(context)
                                    .add(StorageDeleteStorage(storageId));
                                if (state.storage.parent != null) {
                                  BlocProvider.of<StorageBloc>(context).add(
                                      StorageRefreshStorageDetail(
                                          id: state.storage.parent.id));
                                } else {
                                  BlocProvider.of<StorageBloc>(context)
                                      .add(StorageRefreshRoot());
                                }
                                BlocProvider.of<StorageBloc>(context)
                                    .add(StorageRefreshStorages());
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
            body: RefreshIndicator(
              onRefresh: () async {
                BlocProvider.of<StorageBloc>(context)
                    .add(StorageRefreshStorageDetail(id: storageId));
              },
              child: StorageItemList(
                items: state.storage.items.toList(),
                storages: state.storage.children.toList(),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return StorageAddItemEditPage(
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
        return Container();
      },
    );
  }
}
