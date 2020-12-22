import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/storage/blocs.dart';

import 'package:smart_home/blocs/storage/recycle_bin/recycle_bin_bloc.dart';
import 'package:smart_home/blocs/storage/storage_home/storage_home_bloc.dart';
import 'package:smart_home/models/storage.dart';
import 'package:smart_home/pages/error_page.dart';
import 'package:smart_home/pages/loading_page.dart';
import 'package:smart_home/pages/storage/item_datail_page.dart';
import 'package:smart_home/repositories/repositories.dart';
import 'package:smart_home/utils/date_format_extension.dart';
import 'package:smart_home/widgets/show_snack_bar.dart';

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
              return ErrorPage(
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
                      showInfoSnackBar('物品 ${state.item.name} 恢复成功');
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
            return LoadingPage();
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
  return Dismissible(
    key: ValueKey(item.name),
    background: Container(
      color: Colors.green,
    ),
    onDismissed: (direction) {
      BlocProvider.of<ItemEditBloc>(context).add(ItemRestored(item: item));
      showInfoSnackBar('正在恢复...', duration: 1);
    },
    child: ListTile(
      title: text,
      subtitle: Text(item.description ?? ''),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ItemDetailPage(
              itemId: item.id,
              storageHomeBloc: BlocProvider.of<StorageHomeBloc>(context),
            ),
          ),
        );
      },
    ),
  );
}
