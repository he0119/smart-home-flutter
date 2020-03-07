import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/storage/item_form_bloc.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/widgets/item_form.dart';

class StorageAddItemEditPage extends StatelessWidget {
  final bool isEditing;
  final String storageId;
  final Item item;

  const StorageAddItemEditPage({
    Key key,
    @required this.isEditing,
    this.item,
    this.storageId,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '编辑物品' : '添加物品'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: BlocProvider(
          create: (context) => ItemFormBloc(),
          child: ItemForm(
            isEditing: isEditing,
            item: item,
            storageId: storageId,
          ),
        ),
      ),
    );
  }
}
