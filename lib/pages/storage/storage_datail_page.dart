import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/models/models.dart';

class StorageStoragePage extends StatelessWidget {
  final Storage storage;

  const StorageStoragePage({Key key, @required this.storage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(storage.name),
      ),
      body: _StorageDetail(
        items: storage.items.toList(),
        storages: storage.children.toList(),
      ),
    );
  }
}

class _StorageDetail extends StatelessWidget {
  final List<Item> items;
  final List<Storage> storages;

  const _StorageDetail({Key key, this.items, this.storages}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<dynamic> merged = List.from(items)..addAll(storages);
    return ListView.builder(
      itemCount: merged.length,
      itemBuilder: (BuildContext context, int index) {
        return _StorageDetailItem(item: merged[index]);
      },
    );
  }
}

class _StorageDetailItem extends StatelessWidget {
  final dynamic item;

  const _StorageDetailItem({Key key, @required this.item}) : super(key: key);

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
        onTap: () async {},
      );
    } else {
      return ListTile(
        leading: const Icon(
          Icons.storage,
          size: 34.0,
        ),
        title: Text(item.name),
        subtitle: Text(item.description ?? ''),
        onTap: () async {
          BlocProvider.of<StorageBloc>(context)
            .add(StorageStorageDetail(item.id));
        },
      );
    }
  }
}
