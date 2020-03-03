import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/models/models.dart';

class StorageItemList extends StatelessWidget {
  final List<Item> items;
  final List<Storage> storages;

  const StorageItemList({Key key, this.items, this.storages}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<dynamic> merged = List.from(items)..addAll(storages);
    return ListView.separated(
      itemCount: merged.length,
      itemBuilder: (BuildContext context, int index) {
        return _StorageItemListItem(item: merged[index]);
      },
      separatorBuilder: (contexit, index) => Divider(),
    );
  }
}

class _StorageItemListItem extends StatelessWidget {
  final dynamic item;

  const _StorageItemListItem({Key key, @required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (item is Item) {
      return ListTile(
        leading: const Icon(
          Icons.insert_drive_file,
          size: 34.0,
        ),
        title: Text(item.name),
        subtitle: Text(item.description ?? ''),
        onTap: () {
          BlocProvider.of<StorageBloc>(context).add(StorageItemDetail(item.id));
        },
      );
    } else {
      return ListTile(
        leading: const Icon(
          Icons.storage,
          size: 34.0,
        ),
        title: Text(item.name),
        subtitle: Text(item.description ?? ''),
        onTap: () {
          BlocProvider.of<StorageBloc>(context)
              .add(StorageStorageDetail(item.id));
        },
      );
    }
  }
}
