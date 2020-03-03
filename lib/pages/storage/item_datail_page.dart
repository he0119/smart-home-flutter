import 'package:flutter/material.dart';
import 'package:smart_home/models/models.dart';

class StorageItemPage extends StatelessWidget {
  final Item item;

  const StorageItemPage({Key key, @required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListTile(
        leading: const Icon(
          Icons.storage,
          size: 34.0,
        ),
        title: Text(item.name),
        subtitle: Text(item.description ?? ''),
        onTap: () async {},
      ),
    );
  }
}
