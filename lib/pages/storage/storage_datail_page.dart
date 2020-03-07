import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/pages/storage/item_add_edit_page.dart';
import 'package:smart_home/pages/storage/storage_add_edit_page.dart';
import 'package:smart_home/widgets/storage_item_list.dart';

enum Menu { edit }

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
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: Menu.edit,
                      child: Text('编辑'),
                    )
                  ],
                )
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                BlocProvider.of<StorageBloc>(context)
                    .add(StorageRefreshStorageDetail(storageId));
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
