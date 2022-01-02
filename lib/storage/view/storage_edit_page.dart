import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthome/storage/bloc/blocs.dart';
import 'package:smarthome/storage/model/models.dart';
import 'package:smarthome/storage/view/widgets/storage_picker_formfield.dart';
import 'package:smarthome/utils/show_snack_bar.dart';
import 'package:smarthome/widgets/rounded_raised_button.dart';

class StorageEditPage extends StatefulWidget {
  final bool isEditing;
  final Storage? storage;

  const StorageEditPage({
    Key? key,
    required this.isEditing,
    required this.storage,
  }) : super(key: key);

  @override
  _StorageEditPageState createState() => _StorageEditPageState();
}

class _StorageEditPageState extends State<StorageEditPage> {
  String? parentId;
  TextEditingController? _nameController;
  TextEditingController? _descriptionController;
  FocusNode? _nameFocusNode;
  FocusNode? _descriptionFocusNode;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    if (widget.isEditing) {
      _nameController = TextEditingController(text: widget.storage!.name);
      _descriptionController =
          TextEditingController(text: widget.storage!.description);
      parentId = widget.storage!.parent?.id;
    } else {
      _nameController = TextEditingController();
      _descriptionController = TextEditingController();
      parentId = widget.storage?.id;
    }

    _nameFocusNode = FocusNode();
    _descriptionFocusNode = FocusNode();

    super.initState();
  }

  @override
  void dispose() {
    _nameController!.dispose();
    _descriptionController!.dispose();
    _nameFocusNode!.dispose();
    _descriptionFocusNode!.dispose();

    super.dispose();
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode? nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  void _onSubmitPressed() {
    if (widget.isEditing) {
      BlocProvider.of<StorageEditBloc>(context).add(
        StorageUpdated(
          id: widget.storage!.id,
          name: _nameController!.text,
          parentId: parentId,
          oldParentId: widget.storage!.parent?.id,
          description: _descriptionController!.text,
        ),
      );
    } else {
      BlocProvider.of<StorageEditBloc>(context).add(
        StorageAdded(
          name: _nameController!.text,
          parentId: parentId,
          description: _descriptionController!.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.isEditing
            ? Text('编辑 ${widget.storage!.name}')
            : const Text('添加位置'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: BlocConsumer<StorageEditBloc, StorageEditState>(
          listener: (context, state) {
            if (state is StorageEditInProgress) {
              showInfoSnackBar('正在提交...', duration: 1);
            }
            if (state is StorageAddSuccess) {
              showInfoSnackBar('位置 ${state.storage.name} 添加成功');
            }
            if (state is StorageUpdateSuccess) {
              showInfoSnackBar('位置 ${state.storage.name} 修改成功');
            }
            if (state is StorageEditFailure) {
              showErrorSnackBar(state.message);
            }
            // 位置添加和修改成功过后自动返回位置详情界面
            if (state is StorageAddSuccess || state is StorageUpdateSuccess) {
              Navigator.of(context).pop(true);
            }
          },
          builder: (context, state) => Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '名称',
                    ),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(200),
                    ],
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return '名称不能为空';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                    focusNode: _nameFocusNode,
                    onFieldSubmitted: (_) {
                      _fieldFocusChange(
                          context, _nameFocusNode!, _descriptionFocusNode);
                    },
                  ),
                  // FIXME: 无法选择 家 这个位置
                  StorageFormField(
                    decoration: const InputDecoration(
                      labelText: '属于',
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onChanged: (Storage? value) {
                      if (value != null) {
                        parentId = value.id;
                      }
                    },
                    initialValue: widget.isEditing
                        ? widget.storage!.parent
                        : widget.storage,
                    validator: (value) {
                      if (value == null) {
                        return '请选择一个位置';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: '备注',
                    ),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(200),
                    ],
                    focusNode: _descriptionFocusNode,
                  ),
                  RoundedRaisedButton(
                    onPressed: (state is! StorageEditInProgress)
                        ? () {
                            if (_formKey.currentState!.validate()) {
                              _onSubmitPressed();
                            }
                          }
                        : null,
                    child: const Text('提交'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
