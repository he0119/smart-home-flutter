import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthome/routers/delegate.dart';
import 'package:smarthome/storage/bloc/blocs.dart';
import 'package:smarthome/storage/model/models.dart';
import 'package:smarthome/storage/repository/storage_repository.dart';
import 'package:smarthome/storage/view/item_datail_page.dart';
import 'package:smarthome/utils/date_format_extension.dart';
import 'package:smarthome/utils/show_snack_bar.dart';
import 'package:smarthome/widgets/center_loading_indicator.dart';
import 'package:smarthome/widgets/error_message_button.dart';
import 'package:smarthome/widgets/home_page.dart';
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
            )..add(const RecycleBinFetched()),
          ),
          BlocProvider<ItemEditBloc>(
            create: (context) => ItemEditBloc(
              storageRepository:
                  RepositoryProvider.of<StorageRepository>(context),
            ),
          )
        ],
        child: const RecycleBinScreen(),
      ),
    );
  }
}

class RecycleBinScreen extends StatelessWidget {
  const RecycleBinScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecycleBinBloc, RecycleBinState>(
      builder: (context, state) {
        return MySliverPage(
          title: '回收站',
          onRefresh: () async {
            BlocProvider.of<RecycleBinBloc>(context)
                .add(const RecycleBinFetched(cache: false));
          },
          slivers: [
            if (state is RecycleBinFailure)
              SliverErrorMessageButton(
                message: state.message,
                onPressed: () {
                  BlocProvider.of<ConsumablesBloc>(context)
                      .add(const ConsumablesFetched(cache: false));
                },
              ),
            if (state is RecycleBinInProgress)
              const SliverCenterLoadingIndicator(),
            if (state is RecycleBinSuccess)
              BlocListener<ItemEditBloc, ItemEditState>(
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
                  child: SliverInfiniteList(
                    itemBuilder: _buildItem,
                    items: state.items,
                    hasReachedMax: state.hasReachedMax,
                    onFetch: () => context
                        .read<RecycleBinBloc>()
                        .add(const RecycleBinFetched()),
                  )),
          ],
        );
      },
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
          style: const TextStyle(fontWeight: FontWeight.bold),
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
      MyRouterDelegate.of(context).push(ItemDetailPage(itemId: item.id));
    },
    trailing: Tooltip(
      message: '恢复',
      child: IconButton(
        icon: const Icon(Icons.undo),
        onPressed: () async {
          final recycleBinBloc = BlocProvider.of<RecycleBinBloc>(context);

          await showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('恢复物品'),
              content: const Text('你确认要恢复该物品？'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('否'),
                ),
                TextButton(
                  onPressed: () {
                    BlocProvider.of<ItemEditBloc>(context)
                        .add(ItemRestored(item: item));
                    showInfoSnackBar('正在恢复...', duration: 1);
                    Navigator.of(context).pop();
                  },
                  child: const Text('是'),
                ),
              ],
            ),
          );
          recycleBinBloc.add(const RecycleBinFetched(cache: false));
        },
      ),
    ),
  );
}
