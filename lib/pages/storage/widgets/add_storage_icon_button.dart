import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/storage/blocs.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/pages/storage/storage_edit_page.dart';
import 'package:smart_home/repositories/repositories.dart';

class AddStorageIconButton extends StatelessWidget {
  const AddStorageIconButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '添加位置',
      child: IconButton(
        icon: Icon(Icons.add),
        onPressed: () async {
          List<Storage> listofStorages =
              await RepositoryProvider.of<StorageRepository>(context)
                  .storages();
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => BlocProvider<StorageEditBloc>(
              create: (_) => StorageEditBloc(
                storageRepository:
                    RepositoryProvider.of<StorageRepository>(context),
                storageDetailBloc: BlocProvider.of<StorageDetailBloc>(context),
              ),
              child: StorageEditPage(
                isEditing: false,
                listofStorages: listofStorages,
              ),
            ),
          ));
        },
      ),
    );
  }
}
