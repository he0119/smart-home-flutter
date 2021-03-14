import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smarthome/blocs/storage/blocs.dart';
import 'package:smarthome/models/storage.dart';
import 'package:smarthome/pages/storage/storage_edit_page.dart';
import 'package:smarthome/repositories/repositories.dart';

class AddStorageIconButton extends StatelessWidget {
  final Storage storage;

  const AddStorageIconButton({
    Key key,
    this.storage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '添加位置',
      child: IconButton(
        icon: Icon(Icons.add),
        onPressed: () async {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => BlocProvider<StorageEditBloc>(
              create: (_) => StorageEditBloc(
                storageRepository:
                    RepositoryProvider.of<StorageRepository>(context),
              ),
              child: StorageEditPage(
                isEditing: false,
                storage: storage,
              ),
            ),
          ));
        },
      ),
    );
  }
}
