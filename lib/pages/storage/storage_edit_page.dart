import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/blocs/storage/blocs.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/models/storage.dart';
import 'package:smart_home/widgets/show_snack_bar.dart';

class StorageEditPage extends StatefulWidget {
  final bool isEditing;
  final Storage storage;
  final String storageId;
  final List<Storage> listofStorages;

  const StorageEditPage({
    Key key,
    @required this.isEditing,
    @required this.listofStorages,
    this.storage,
    this.storageId,
  }) : super(key: key);

  @override
  _StorageEditPageState createState() => _StorageEditPageState();
}

class _StorageEditPageState extends State<StorageEditPage> {
  String parentId;
  TextEditingController _nameController;
  TextEditingController _descriptionController;
  FocusNode _nameFocusNode;
  FocusNode _descriptionFocusNode;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    if (widget.isEditing) {
      _nameController = TextEditingController(text: widget.storage.name);
      _descriptionController =
          TextEditingController(text: widget.storage.description);
      parentId = widget.storage.parent?.id;
    } else {
      _nameController = TextEditingController();
      _descriptionController = TextEditingController();
      parentId = widget.storageId;
    }

    _nameFocusNode = FocusNode();
    _descriptionFocusNode = FocusNode();

    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _nameFocusNode.dispose();
    _descriptionFocusNode.dispose();

    super.dispose();
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  void _onSubmitPressed() {
    if (widget.isEditing) {
      BlocProvider.of<StorageEditBloc>(context).add(
        StorageUpdated(
          id: widget.storage.id,
          name: _nameController.text,
          parentId: parentId,
          oldParentId: widget.storage.parent?.id,
          description: _descriptionController.text,
        ),
      );
    } else {
      BlocProvider.of<StorageEditBloc>(context).add(
        StorageAdded(
          name: _nameController.text,
          parentId: parentId,
          description: _descriptionController.text,
        ),
      );
    }
  }

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
          title: widget.isEditing
              ? Text('编辑 ${widget.storage.name}')
              : Text('添加位置'),
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
              showErrorSnackBar(
                context,
                state.message,
                duration: state.duration,
              );
            }
            if (state is SnackBarSuccess && state.type == MessageType.info) {
              showInfoSnackBar(
                context,
                state.message,
                duration: state.duration,
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: BlocConsumer<StorageEditBloc, StorageEditState>(
              listener: (context, state) {
                if (state is StorageEditInProgress) {
                  showInfoSnackBar(context, '正在提交...', duration: 1);
                }
              },
              builder: (context, state) => Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: '名称',
                        ),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(200),
                        ],
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value.isEmpty) {
                            return '名称不能为空';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                        focusNode: _nameFocusNode,
                        onFieldSubmitted: (_) {
                          _fieldFocusChange(
                              context, _nameFocusNode, _descriptionFocusNode);
                        },
                      ),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: '属于',
                        ),
                        value: widget.isEditing
                            ? widget.storage.parent?.id
                            : widget.storageId,
                        items: widget.listofStorages
                            .map((e) => DropdownMenuItem(
                                  value: e.id,
                                  child: Text(e.name),
                                ))
                            .toList(),
                        onChanged: (value) {
                          parentId = value;
                        },
                      ),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: '备注',
                        ),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(200),
                        ],
                        focusNode: _descriptionFocusNode,
                      ),
                      RaisedButton(
                        onPressed: (state is! StorageEditInProgress)
                            ? () {
                                if (_formKey.currentState.validate()) {
                                  _onSubmitPressed();
                                }
                              }
                            : null,
                        child: Text('提交'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
