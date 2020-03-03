import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_home/models/models.dart';

class StorageItemPage extends StatelessWidget {
  final Item item;

  const StorageItemPage({Key key, @required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(item.name),
        ),
        body: ListView(
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
                  ? DateFormat.yMMMd('zh').add_jm().format(item.expirationDate.toLocal())
                  : ''),
            ),
            ListTile(
              title: Text('更新日期'),
              trailing: Text(item.updateDate != null
                  ? DateFormat.yMMMd('zh').add_jm().format(item.updateDate.toLocal())
                  : ''),
            ),
            ListTile(
              title: Text('录入者'),
              trailing: Text(item.editor.username),
            ),
          ],
        ));
  }
}
