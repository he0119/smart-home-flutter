import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smarthome/storage/providers/providers.dart';
import 'package:smarthome/utils/show_snack_bar.dart';
import 'package:smarthome/widgets/home_page.dart';
import 'package:smarthome/widgets/rounded_raised_button.dart';

class PictureAddPage extends StatelessWidget {
  /// 物品 ID
  final String itemId;

  const PictureAddPage({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    return PictureAddScreen(itemId: itemId);
  }
}

class PictureAddScreen extends ConsumerStatefulWidget {
  /// 物品 ID
  final String itemId;

  const PictureAddScreen({super.key, required this.itemId});

  @override
  ConsumerState<PictureAddScreen> createState() => _PictureAddScreenState();
}

class _PictureAddScreenState extends ConsumerState<PictureAddScreen> {
  TextEditingController? _descriptionController;
  String? picturePath;

  final _picker = ImagePicker();
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
    final state = ref.watch(pictureEditProvider);

    ref.listen<PictureEditState>(pictureEditProvider, (previous, state) {
      if (state.status == PictureEditStatus.addSuccess) {
        showInfoSnackBar('图片添加成功');
        Navigator.of(context).pop();
      }
      if (state.status == PictureEditStatus.failure) {
        showErrorSnackBar(state.errorMessage);
      }
    });

    return MySliverScaffold(
      title: const Text('添加图片'),
      sliver: SliverToBoxAdapter(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
            child: Column(
              children: [
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: '备注'),
                  inputFormatters: [LengthLimitingTextInputFormatter(200)],
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
                          kIsWeb
                              ? Image.network(picturePath!)
                              : Image.file(File(picturePath!)),
                          if (state.status == PictureEditStatus.loading)
                            const CircularProgressIndicator(),
                        ],
                      )
                    : const SizedBox(
                        height: 300,
                        child: Center(child: Text('无图片')),
                      ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RoundedRaisedButton(
                      onPressed: () async {
                        final image = await _picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        setState(() {
                          picturePath = image?.path;
                        });
                      },
                      child: const Text('相册'),
                    ),
                    if (!kIsWeb) const SizedBox(width: 20),
                    if (!kIsWeb)
                      RoundedRaisedButton(
                        onPressed: () async {
                          final photo = await _picker.pickImage(
                            source: ImageSource.camera,
                          );
                          setState(() {
                            picturePath = photo?.path;
                          });
                        },
                        child: const Text('拍照'),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RoundedRaisedButton(
                    onPressed:
                        (state.status != PictureEditStatus.loading &&
                            picturePath != null)
                        ? () {
                            if (_formKey.currentState!.validate()) {
                              _onSubmitPressed();
                            }
                          }
                        : null,
                    child: const Text('上传'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onSubmitPressed() {
    showInfoSnackBar('正在上传...');
    ref
        .read(pictureEditProvider.notifier)
        .addPicture(
          itemId: widget.itemId,
          picturePath: picturePath!,
          description: _descriptionController!.text,
          boxX: 0.5,
          boxY: 0.5,
          boxH: 0.5,
          boxW: 0.5,
        );
  }
}
