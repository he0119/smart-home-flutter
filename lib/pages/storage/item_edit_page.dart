import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/storage/item_form_bloc.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/widgets/item_form.dart';

class StorageItemEditPage extends StatelessWidget {
  final Item item;
  const StorageItemEditPage({Key key, @required this.item}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('编辑物品'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: BlocProvider(
          create: (context) => ItemFormBloc(),
          child: ItemForm(item: item),
        ),
      ),
    );
  }
}
