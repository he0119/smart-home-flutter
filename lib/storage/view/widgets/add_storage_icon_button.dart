import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthome/storage/bloc/blocs.dart';
import 'package:smarthome/storage/model/storage.dart';
import 'package:smarthome/storage/repository/storage_repository.dart';
import 'package:smarthome/storage/view/storage_edit_page.dart';

class AddStorageIconButton extends StatelessWidget {
  final Storage? storage;

  const AddStorageIconButton({
    super.key,
    this.storage,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '添加位置',
      child: IconButton(
        icon: const Icon(Icons.add),
        onPressed: () async {
          final storageDetailBloc = context.read<StorageDetailBloc>();

          final r = await Navigator.of(context).push(
            MaterialPageRoute(
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
            ),
          );
          if (r == true) {
            storageDetailBloc.add(
              StorageDetailFetched(id: storage?.id ?? '', cache: false),
            );
          }
        },
      ),
    );
  }
}
