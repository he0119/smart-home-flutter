import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/widgets/storage_item_list.dart';

class StorageHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    BlocProvider.of<StorageBloc>(context).add(StorageStarted());
    return _StorageHomePage();
  }
}

class _StorageHomePage extends StatelessWidget {
  const _StorageHomePage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StorageBloc, StorageState>(
      builder: (context, state) {
        if (state is StorageRootResults) {
          return StorageItemList(items: [], storages: state.storages);
        }
        return CircularProgressIndicator();
      },
      condition: (previous, current) {
        if (current is StorageRootResults) {
          return true;
        }
        return false;
      },
    );
  }
}
