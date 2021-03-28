import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthome/storage/bloc/blocs.dart';
import 'package:smarthome/routers/delegate.dart';
import 'package:smarthome/storage/model/models.dart';
import 'package:smarthome/storage/repository/storage_repository.dart';
import 'package:smarthome/utils/date_format_extension.dart';
import 'package:smarthome/widgets/center_loading_indicator.dart';
import 'package:smarthome/widgets/error_message_button.dart';
import 'package:smarthome/utils/show_snack_bar.dart';
import 'package:smarthome/widgets/infinite_list.dart';

class RecycleBinPage extends Page {
  RecycleBinPage() : super(key: UniqueKey(), name: '/recyclebin');

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider<RecycleBinBloc>(
            create: (context) => RecycleBinBloc(
              storageRepository:
                  RepositoryProvider.of<StorageRepository>(context),
            )..add(RecycleBinFetched()),
          ),
          BlocProvider<ItemEditBloc>(
            create: (context) => ItemEditBloc(
              storageRepository:
                  RepositoryProvider.of<StorageRepository>(context),
            ),
          )
        ],
        child: RecycleBinScreen(),
      ),
    );
  }
}

class RecycleBinScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    .add(RecycleBinFetched(cache: false));
              },
            );
          }
          if (state is RecycleBinSuccess) {
            return RefreshIndicator(
              onRefresh: () async {
                BlocProvider.of<RecycleBinBloc>(context)
                    .add(RecycleBinFetched(cache: false));
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
                  child: InfiniteList(
                    itemBuilder: _buildItem,
                    items: state.items,
                    hasReachedMax: state.hasReachedMax,
                    onFetch: () =>
                        context.read<RecycleBinBloc>().add(RecycleBinFetched()),
                  )),
            );
          }
          return CenterLoadingIndicator();
        },
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
          text: '（${item.deletedAt!.differenceFromNowStr()}删除）',
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
                TextButton(
                  child: Text('否'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
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
          BlocProvider.of<RecycleBinBloc>(context)
              .add(RecycleBinFetched(cache: false));
        },
      ),
    ),
  );
}