import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/routers/delegate.dart';
import 'package:smarthome/storage/bloc/blocs.dart';
import 'package:smarthome/storage/model/models.dart';
import 'package:smarthome/storage/providers/recycle_bin_provider.dart';
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
      builder: (context) => BlocProvider<ItemEditBloc>(
        create: (context) => ItemEditBloc(
          storageRepository: RepositoryProvider.of<StorageRepository>(context),
        ),
        child: const RecycleBinScreen(),
      ),
    );
  }
}

class RecycleBinScreen extends ConsumerWidget {
  const RecycleBinScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recycleBinProvider);
    return MySliverScaffold(
      title: const Text('回收站'),
      onRefresh: () async {
        ref.read(recycleBinProvider.notifier).fetch(cache: false);
      },
      slivers: [
        if (state.status == RecycleBinStatus.failure)
          SliverErrorMessageButton(
            message: state.errorMessage,
            onPressed: () {
              ref.read(recycleBinProvider.notifier).fetch(cache: false);
            },
          ),
        if (state.status == RecycleBinStatus.loading)
          const SliverCenterLoadingIndicator(),
        if (state.status == RecycleBinStatus.success)
          BlocListener<ItemEditBloc, ItemEditState>(
            listener: (context, state) {
              if (state is ItemRestoreSuccess) {
                showInfoSnackBar('物品 ${state.item.name} 恢复成功', duration: 2);
              }
              if (state is ItemEditFailure) {
                showErrorSnackBar(state.message);
              }
            },
            child: SliverInfiniteList(
              itemBuilder: _buildItem,
              items: state.items,
              hasReachedMax: state.hasReachedMax,
              onFetch: () => ref.read(recycleBinProvider.notifier).fetch(),
            ),
          ),
      ],
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
        TextSpan(text: '（${item.deletedAt!.differenceFromNowStr()}删除）'),
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
                    BlocProvider.of<ItemEditBloc>(
                      context,
                    ).add(ItemRestored(item: item));
                    showInfoSnackBar('正在恢复...', duration: 1);
                    Navigator.of(context).pop();
                  },
                  child: const Text('是'),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}
