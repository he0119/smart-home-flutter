import 'package:flutter/material.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/widgets/storage_item_list.dart';

class StorageStoragePage extends StatelessWidget {
  final Storage storage;

  const StorageStoragePage({Key key, @required this.storage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(storage.name),
      ),
      body: StorageItemList(
        items: storage.items.toList(),
        storages: storage.children.toList(),
      ),
    );
  }
}
