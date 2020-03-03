import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/pages/storage/storage_datail_page.dart';

class StorageHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StorageBloc, StorageState>(
      listener: (context, state) {
        if (state is StorageRootResults) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => StorageRootList(storages: state.storages)),
          );
        }
        if (state is StorageStorageDetailResults) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => StorageStoragePage(storage: state.storage)),
          );
        }
      },
      builder: (context, state) {
        if (state is StorageLoading) {
          return CircularProgressIndicator();
        }
        return FlatButton(
          child: Text('管理'),
          onPressed: () {
            BlocProvider.of<StorageBloc>(context).add(StorageRoot());
          },
        );
      },
    );
  }
}

class StorageRootList extends StatelessWidget {
  final List<Storage> storages;
  const StorageRootList({Key key, @required this.storages}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('物品管理'),
      ),
      body: ListView.builder(
        itemCount: storages.length,
        itemBuilder: (BuildContext context, int index) {
          return _RootStorageItem(item: storages[index]);
        },
      ),
    );
  }
}

class _RootStorageItem extends StatelessWidget {
  final Storage item;

  const _RootStorageItem({Key key, @required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.storage,
        size: 34.0,
      ),
      title: Text(item.name),
      subtitle: Text(item.description ?? ''),
      onTap: () async {
        BlocProvider.of<StorageBloc>(context)
            .add(StorageStorageDetail(item.id));
      },
    );
  }
}
