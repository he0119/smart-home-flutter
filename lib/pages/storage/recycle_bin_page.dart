import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smart_home/blocs/storage/blocs.dart';
import 'package:smart_home/models/storage.dart';
import 'package:smart_home/repositories/repositories.dart';
import 'package:smart_home/routers/delegate.dart';
import 'package:smart_home/utils/date_format_extension.dart';
import 'package:smart_home/widgets/center_loading_indicator.dart';
import 'package:smart_home/widgets/error_message_button.dart';
import 'package:smart_home/utils/show_snack_bar.dart';

class RecycleBinPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RecycleBinBloc>(
          create: (context) => RecycleBinBloc(
            storageRepository:
                RepositoryProvider.of<StorageRepository>(context),
          )..add(RecycleBinRefreshed()),
        ),
        BlocProvider<ItemEditBloc>(
          create: (context) => ItemEditBloc(
            storageRepository:
                RepositoryProvider.of<StorageRepository>(context),
          ),
        )
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text('回收站'),
        ),
        body: BlocBuilder<RecycleBinBloc, RecycleBinState>(
          builder: (context, state) {
            if (state is RecycleBinFailure) {
              return ErrorMessageButton(
                message: state.message,
                onPressed: () {
                  BlocProvider.of<RecycleBinBloc>(context)
                      .add(RecycleBinRefreshed());
                },
              );
            }
            if (state is RecycleBinSuccess) {
              return RefreshIndicator(
                onRefresh: () async {
                  BlocProvider.of<RecycleBinBloc>(context)
                      .add(RecycleBinRefreshed());
                },
                child: BlocListener<ItemEditBloc, ItemEditState>(
                  listener: (context, state) {
                    if (state is ItemRestoreSuccess) {
                      showInfoSnackBar(
                        '物品 ${state.item.name} 恢复成功',
                        duration: 2,
                      );
                    }
                    if (state is ItemEditFailure) {
                      showErrorSnackBar(state.message);
                    }
                  },
                  child: ListView.builder(
                    itemCount: state.items.length,
                    itemBuilder: (context, index) =>
                        _buildItem(context, state.items[index]),
                  ),
                ),
              );
            }
            return CenterLoadingIndicator();
          },
        ),
      ),
    );
  }
}

Widget _buildItem(BuildContext context, Item item) {
  final text = RichText(
    text: TextSpan(
      style: DefaultTextStyle.of(context).style,
      children: <TextSpan>[
        TextSpan(
          text: item.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text: '（${item.deletedAt.differenceFromNowStr()}删除）',
        ),
      ],
    ),
  );
  return ListTile(
    title: text,
    subtitle: Text(item.description ?? ''),
    onTap: () {
      MyRouterDelegate.of(context).addItemPage(item: item);
    },
    trailing: Tooltip(
      message: '恢复',
      child: IconButton(
        icon: Icon(Icons.undo),
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('恢复物品'),
              content: Text('你确认要恢复该物品？'),
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
                    BlocProvider.of<ItemEditBloc>(context)
                        .add(ItemRestored(item: item));
                    showInfoSnackBar('正在恢复...', duration: 1);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
          BlocProvider.of<RecycleBinBloc>(context).add(RecycleBinRefreshed());
        },
      ),
    ),
  );
}
