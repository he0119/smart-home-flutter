import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intent/intent.dart' as android_intent;
import 'package:intent/action.dart' as android_action;

import 'package:smarthome/storage/bloc/blocs.dart';
import 'package:smarthome/storage/repository/storage_repository.dart';
import 'package:smarthome/routers/delegate.dart';
import 'package:smarthome/utils/show_snack_bar.dart';
import 'package:smarthome/widgets/rounded_raised_button.dart';

class PictureAddPage extends Page {
  /// 物品 ID
  final String itemId;

  PictureAddPage({
    required this.itemId,
  }) : super(
          key: ValueKey(itemId),
          name: '/item/$itemId/picture/add',
        );

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (context) => BlocProvider<PictureEditBloc>(
        create: (context) => PictureEditBloc(
          storageRepository: RepositoryProvider.of<StorageRepository>(context),
        ),
        child: PictureAddScreen(
          itemId: itemId,
        ),
      ),
    );
  }
}

class PictureAddScreen extends StatefulWidget {
  /// 物品 ID
  final String itemId;

  PictureAddScreen({
    Key? key,
    required this.itemId,
  }) : super(key: key);

  @override
  _PictureAddScreenState createState() => _PictureAddScreenState();
}

class _PictureAddScreenState extends State<PictureAddScreen> {
  TextEditingController? _descriptionController;
  String? picturePath;

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _descriptionController!.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _descriptionController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PictureEditBloc, PictureEditState>(
      listener: (context, state) {
        if (state is PictureAddSuccess) {
          showInfoSnackBar('图片添加成功');
          MyRouterDelegate.of(context).pop();
        }
        if (state is PictureEditFailure) {
          showErrorSnackBar(state.message);
        }
      },
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: const Text('添加图片'),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: '备注',
                    ),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(200),
                    ],
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return '备注不能为空';
                      }
                      return null;
                    },
                  ),
                  picturePath != null
                      ? Stack(
                          alignment: AlignmentDirectional.center,
                          children: <Widget>[
                            const CircularProgressIndicator(),
                            Image.file(File(picturePath!)),
                            if (state is PictureEditInProgress)
                              const CircularProgressIndicator(),
                          ],
                        )
                      : SizedBox(
                          height: 300,
                          child: Container(
                            child: const Center(
                              child: Text('无图片'),
                            ),
                          ),
                        ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RoundedRaisedButton(
                        onPressed: () {
                          android_intent.Intent()
                            ..setAction(
                                android_action.Action.ACTION_IMAGE_CAPTURE)
                            ..startActivityForResult().then((data) {
                              setState(() {
                                picturePath = data[0];
                              });
                            }, onError: print);
                        },
                        child: const Text('拍照'),
                      ),
                    ],
                  ),
                  RoundedRaisedButton(
                    onPressed:
                        (state is! PictureEditInProgress && picturePath != null)
                            ? () {
                                if (_formKey.currentState!.validate()) {
                                  _onSubmitPressed();
                                }
                              }
                            : null,
                    child: const Text('上传'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onSubmitPressed() {
    showInfoSnackBar('正在上传...');
    // 默认物品就在图片正中，并占满整个屏幕
    BlocProvider.of<PictureEditBloc>(context).add(
      PictureAdded(
        itemId: widget.itemId,
        picturePath: picturePath!,
        description: _descriptionController!.text,
        boxX: 0.5,
        boxY: 0.5,
        boxH: 0.5,
        boxW: 0.5,
      ),
    );
  }
}
