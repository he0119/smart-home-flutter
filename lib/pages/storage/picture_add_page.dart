import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smart_home/blocs/storage/blocs.dart';
import 'package:smart_home/repositories/repositories.dart';
import 'package:smart_home/routers/delegate.dart';
import 'package:smart_home/utils/show_snack_bar.dart';

class PictureAddPage extends Page {
  /// 物品 ID
  final String itemId;
  final List<CameraDescription> cameras;

  PictureAddPage({
    @required this.itemId,
    @required this.cameras,
  }) : super(
          key: ValueKey(itemId),
          name: '/picture/add/$itemId',
        );

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (context) => TakePictureScreen(
        itemId: itemId,
        cameras: cameras,
      ),
    );
  }
}

class TakePictureScreen extends StatefulWidget {
  /// 物品 ID
  final String itemId;
  final List<CameraDescription> cameras;

  const TakePictureScreen({
    Key key,
    @required this.itemId,
    @required this.cameras,
  }) : super(key: key);

  @override
  _TakePictureScreenState createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.cameras.first,
      ResolutionPreset.max,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('添加图片'),
      ),
      body: Center(
        child: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return CameraPreview(_controller);
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        onPressed: () async {
          try {
            await _initializeControllerFuture;
            final picture = await _controller.takePicture();

            // If the picture was taken, display it on a new screen.
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider<PictureEditBloc>(
                  create: (context) => PictureEditBloc(
                    storageRepository:
                        RepositoryProvider.of<StorageRepository>(context),
                  ),
                  child: DisplayPictureScreen(
                    itemId: widget.itemId,
                    picturePath: picture?.path,
                  ),
                ),
              ),
            );
          } catch (e) {
            showErrorSnackBar(e);
          }
        },
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
      child: Scaffold(
        appBar: AppBar(title: Text('添加图片')),
        body: Center(
          child: Image.file(File(picturePath)),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.check),
          onPressed: () {
            showInfoSnackBar('正在上传...');
            BlocProvider.of<PictureEditBloc>(context).add(PictureAdded(
                itemId: itemId,
                file: File(picturePath),
                description: '',
                boxX: 0,
                boxY: 0,
                boxH: 0,
                boxW: 0));
          },
        ),
      ),
    );
  }
}
