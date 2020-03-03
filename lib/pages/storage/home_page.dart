import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/pages/storage/item_datail_page.dart';
import 'package:smart_home/pages/storage/storage_datail_page.dart';
import 'package:smart_home/widgets/storage_item_list.dart';

class StorageHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StorageBloc, StorageState>(
      listener: (context, state) {
        if (state is StorageStorageDetailResults) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => StorageStoragePage(storage: state.storage)),
          );
        }
        if (state is StorageItemDetailResults) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => StorageItemPage(item: state.item)),
          );
        }
      },
      builder: (context, state) {
        if (state is StorageRootResults) {
          return StorageItemList(items: [], storages: state.storages);
        }
        return CircularProgressIndicator();
      },
      buildWhen: (previous, current) {
        if (current is StorageRootResults) {
          return true;
        }
        return false;
      },
    );
  }
}
