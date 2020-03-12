import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/pages/storage/item_add_edit_page.dart';
import 'package:smart_home/pages/storage/search_page.dart';
import 'package:smart_home/widgets/show_snack_bar.dart';

enum Menu { edit, delete }

class StorageItemPage extends StatelessWidget {
  final String itemId;

  const StorageItemPage({Key key, @required this.itemId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StorageBloc, StorageState>(
      condition: (previous, current) {
        if (current is StorageItemDetailResults && current.item.id == itemId) {
          return true;
        }
        if (current is StorageItemError && current.id == itemId) {
          return true;
        }
        return false;
      },
      builder: (context, state) {
        if (state is StorageItemDetailResults) {
          return Scaffold(
            appBar: AppBar(
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StorageAddItemEditPage(
                            isEditing: true,
                            item: state.item,
                          ),
                        ),
                      );
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
                                BlocProvider.of<StorageBloc>(context).add(
                                  StorageDeleteItem(item: state.item),
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
                if (state is StorageUpdateItemSuccess && state.id == itemId) {
                  showInfoSnackBar(context, '物品修改成功');
                }
              },
              child: RefreshIndicator(
                onRefresh: () async {
                  BlocProvider.of<StorageBloc>(context)
                      .add(StorageItemDetail(itemId));
                },
                child: _ItemDetail(item: state.item),
              ),
            ),
          );
        }
        if (state is StorageItemError) {
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

class _ItemDetail extends StatelessWidget {
  final Item item;
  const _ItemDetail({Key key, @required this.item}) : super(key: key);

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
          trailing: Text(item.expirationDate != null
              ? DateFormat.yMMMd('zh')
                  .add_jm()
                  .format(item.expirationDate.toLocal())
              : ''),
        ),
        ListTile(
          title: Text('录入者'),
          trailing: Text(item.editor.username),
        ),
        ListTile(
          title: Text('更新时间'),
          trailing: Text(item.updateDate != null
              ? DateFormat.yMMMd('zh')
                  .add_jm()
                  .format(item.updateDate.toLocal())
              : ''),
        ),
        ListTile(
          title: Text('添加时间'),
          trailing: Text(item.dateAdded != null
              ? DateFormat.yMMMd('zh').add_jm().format(item.dateAdded.toLocal())
              : ''),
        ),
      ],
    );
  }
}
