import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/models/models.dart';

class StorageHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StorageBloc, StorageState>(
      builder: (context, state) {
        if (state is StorageRootResults) {
          return ListView.builder(
            itemCount: state.storages.length,
            itemBuilder: (BuildContext context, int index) {
              return _RootStorageItem(item: state.storages[index]);
            },
          );
        }
        return CircularProgressIndicator();
      },
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
      onTap: () async {},
    );
  }
}
