import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/widgets/show_snack_bar.dart';
import 'package:smart_home/widgets/storage_item_list.dart';

class StorageHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    BlocProvider.of<StorageBloc>(context).add(StorageStarted());
    return BlocListener<StorageBloc, StorageState>(
      listener: (context, state) {
        // 物品管理的错误提示
        if (state is StorageStorageError && state.id == '0') {
          showErrorSnackBar(context, state.message);
        }
        if (state is StorageAddStorageSuccess && state.parentId == '0') {
          showInfoSnackBar(context, '位置添加成功');
        }
        if (state is StorageStorageDeleted && state.parentId == '0') {
          showInfoSnackBar(context, '位置删除成功');
        }
        if (state is StorageStorageError && state.parentId == '0') {
          showErrorSnackBar(context, '位置删除失败，${state.message}');
        }
      },
      child: _StorageHomePage(),
    );
  }
}

class _StorageHomePage extends StatelessWidget {
  const _StorageHomePage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StorageBloc, StorageState>(
      condition: (previous, current) {
        if (current is StorageRootResults) {
          return true;
        }
        return false;
      },
      builder: (context, state) {
        if (state is StorageRootResults) {
          return RefreshIndicator(
            onRefresh: () async {
              BlocProvider.of<StorageBloc>(context).add(StorageRefreshRoot());
            },
            child: StorageItemList(items: [], storages: state.storages),
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
