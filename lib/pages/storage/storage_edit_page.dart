import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/blocs/storage/storage_edit/storage_edit_bloc.dart';
import 'package:smart_home/blocs/storage/storage_form/storage_form_bloc.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/models/storage.dart';
import 'package:smart_home/pages/storage/widgets/storage_form.dart';
import 'package:smart_home/repositories/repositories.dart';
import 'package:smart_home/widgets/show_snack_bar.dart';

class StorageEditPage extends StatelessWidget {
  final bool isEditing;
  final Storage storage;
  final String storageId;

  const StorageEditPage({
    Key key,
    @required this.isEditing,
    this.storage,
    this.storageId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<StorageEditBloc, StorageEditState>(
      listener: (context, state) {
        if (state is StorageAddSuccess || state is StorageUpdateSuccess) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: isEditing ? Text('编辑 ${storage.name}') : Text('添加位置'),
        ),
        body: BlocListener<SnackBarBloc, SnackBarState>(
          // 仅在位置修改页面显示特定消息提示
          listenWhen: (previous, current) {
            if (current is SnackBarSuccess &&
                current.position == SnackBarPosition.storageEdit) {
              return true;
            }
            return false;
          },
          listener: (context, state) {
            if (state is SnackBarSuccess && state.type == MessageType.error) {
              showErrorSnackBar(context, state.message);
            }
            if (state is SnackBarSuccess && state.type == MessageType.info) {
              showInfoSnackBar(context, state.message);
            }
          },
          child: BlocProvider(
            create: (context) => StorageFormBloc(
              storageRepository:
                  RepositoryProvider.of<StorageRepository>(context),
              storageEditBloc: BlocProvider.of<StorageEditBloc>(context),
            ),
            child: StorageForm(
              isEditing: isEditing,
              storageId: storageId,
              storage: storage,
            ),
          ),
        ),
      ),
    );
  }
}
