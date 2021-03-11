import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smart_home/blocs/storage/blocs.dart';
import 'package:smart_home/repositories/storage_repository.dart';
import 'package:smart_home/routers/delegate.dart';
import 'package:smart_home/utils/show_snack_bar.dart';

class PictureAddPage extends Page {
  /// 物品 ID
  final String itemId;
  final String picturePath;

  PictureAddPage({
    @required this.itemId,
    @required this.picturePath,
  }) : super(
          key: ValueKey(itemId),
          name: '/picture/add/$itemId',
        );

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (context) => BlocProvider<PictureEditBloc>(
        create: (context) => PictureEditBloc(
          storageRepository: RepositoryProvider.of<StorageRepository>(context),
        ),
        child: DisplayPictureScreen(
          itemId: itemId,
          picturePath: picturePath,
        ),
      ),
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String picturePath;
  final String itemId;

  const DisplayPictureScreen({
    Key key,
    @required this.picturePath,
    @required this.itemId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<PictureEditBloc, PictureEditState>(
      listener: (context, state) {
        if (state is PictureAddSuccess) {
          showInfoSnackBar('图片添加成功');
          MyRouterDelegate.of(context).pop();
        }
        if (state is PictureEditFailure) {
          showErrorSnackBar(state.message);
        }
      },
      child: BlocBuilder<PictureEditBloc, PictureEditState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: Text('添加图片')),
            body: Center(
              child: Image.file(File(picturePath)),
            ),
            floatingActionButton: state is PictureEditInProgress
                ? null
                : FloatingActionButton(
                    child: Icon(Icons.file_upload),
                    onPressed: () {
                      showInfoSnackBar('正在上传...');
                      // 默认物品就在图片正中，并占满整个屏幕
                      BlocProvider.of<PictureEditBloc>(context).add(
                        PictureAdded(
                          itemId: itemId,
                          file: File(picturePath),
                          description: '',
                          boxX: 0.5,
                          boxY: 0.5,
                          boxH: 0.5,
                          boxW: 0.5,
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}
