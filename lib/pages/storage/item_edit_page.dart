import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/blocs/storage/blocs.dart';
import 'package:smart_home/blocs/storage/item_form/item_form_bloc.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/models/storage.dart';
import 'package:smart_home/pages/storage/widgets/item_form.dart';
import 'package:smart_home/repositories/repositories.dart';
import 'package:smart_home/widgets/show_snack_bar.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: isEditing ? Text('编辑 ${item.name}') : Text('添加物品'),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ItemEditBloc, ItemEditState>(listener: (context, state) {
            // 物品添加和修改成功过后自动返回物品详情界面
            if (state is ItemAddSuccess || state is ItemUpdateSuccess) {
              Navigator.of(context).pop();
            }
          }),
          BlocListener<SnackBarBloc, SnackBarState>(
            // 仅在物品修改页面显示特定消息提示
            listenWhen: (previous, current) {
              if (current is SnackBarSuccess &&
                  current.position == SnackBarPosition.itemEdit) {
                return true;
              }
              return false;
            },
            listener: (context, state) {
              if (state is SnackBarSuccess && state.type == MessageType.error) {
                showErrorSnackBar(context, state.message);
              }
              if (state is SnackBarSuccess && state.type == MessageType.info) {
                showInfoSnackBar(context, state.message);
              }
            },
          )
        ],
        child: BlocProvider(
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
