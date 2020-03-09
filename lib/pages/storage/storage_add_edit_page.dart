import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/blocs/storage/storage_form_bloc.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/widgets/storage_form.dart';

class StorageAddEditStoagePage extends StatelessWidget {
  final bool isEditing;
  final String storageId;
  final Storage storage;

  const StorageAddEditStoagePage({
    Key key,
    @required this.isEditing,
    this.storage,
    this.storageId,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '编辑位置' : '添加位置'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: BlocProvider(
          create: (context) => StorageFormBloc(
            storageBloc: BlocProvider.of<StorageBloc>(context),
          ),
          child: StorageForm(
            isEditing: isEditing,
            storage: storage,
            storageId: storageId,
          ),
        ),
      ),
    );
  }
}
