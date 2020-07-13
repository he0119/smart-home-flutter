import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/storage/blocs.dart';
import 'package:smart_home/blocs/storage/item_form/item_form_bloc.dart';
import 'package:smart_home/models/storage.dart';
import 'package:smart_home/pages/storage/widgets/item_form.dart';
import 'package:smart_home/repositories/repositories.dart';

class ItemEditPage extends StatelessWidget {
  final bool isEditing;
  final Item item;
  final String storageId;

  const ItemEditPage({
    Key key,
    @required this.isEditing,
    this.item,
    this.storageId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<ItemEditBloc, ItemEditState>(
      listener: (context, state) {
        if (state is ItemAddSuccess || state is ItemUpdateSuccess) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: isEditing ? Text('编辑 ${item.name}') : Text('添加物品'),
        ),
        body: BlocProvider(
          create: (context) => ItemFormBloc(
            storageRepository:
                RepositoryProvider.of<StorageRepository>(context),
            itemEditBloc: BlocProvider.of<ItemEditBloc>(context),
          ),
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
