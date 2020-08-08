import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/storage/blocs.dart';
import 'package:smart_home/models/models.dart';

class StorageForm extends StatefulWidget {
  final bool isEditing;
  final String storageId;
  final Storage storage;

  StorageForm({
    @required this.isEditing,
    this.storage,
    this.storageId,
  });

  @override
  State<StorageForm> createState() => _StorageFormFormState();
}

class _StorageFormFormState extends State<StorageForm> {
  StorageFormBloc _storageFormBloc;

  FocusNode _nameFocusNode;
  FocusNode _descriptionFocusNode;

  @override
  void initState() {
    super.initState();
    _storageFormBloc = BlocProvider.of<StorageFormBloc>(context);
    _storageFormBloc.add(StorageFormStarted());
    if (widget.isEditing) {
      _storageFormBloc.add(StorageNameChanged(name: widget.storage.name));
      _storageFormBloc
          .add(StorageParentChanged(parent: widget.storage.parent?.id));
      _storageFormBloc.add(
          StorageDescriptionChanged(description: widget.storage.description));
    } else {
      _storageFormBloc.add(StorageNameChanged(name: ''));
      _storageFormBloc.add(StorageParentChanged(parent: widget.storageId));
    }

    _nameFocusNode = FocusNode();
    _descriptionFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
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
      _storageFormBloc.add(StorageFormSubmitted(
        isEditing: true,
        id: widget.storage.id,
        oldParentId: widget.storage.parent?.id,
      ));
    } else {
      _storageFormBloc.add(StorageFormSubmitted(isEditing: false));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StorageFormBloc, StorageFormState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Form(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    initialValue: widget.isEditing ? widget.storage.name : '',
                    onChanged: (value) =>
                        _storageFormBloc.add(StorageNameChanged(name: value)),
                    decoration: InputDecoration(
                      labelText: '名称',
                    ),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(200),
                    ],
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (_) {
                      return state.isNameValid ? null : '名称不能为空';
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
                    value: widget.isEditing ? state.parent : widget.storageId,
                    items: state.listofStorages
                        .map((e) => DropdownMenuItem(
                              value: e.id,
                              child: Text(e.name),
                            ))
                        .toList(),
                    onChanged: (value) {
                      _storageFormBloc.add(StorageParentChanged(parent: value));
                    },
                  ),
                  TextFormField(
                    initialValue:
                        widget.isEditing ? widget.storage.description : '',
                    onChanged: (value) => _storageFormBloc
                        .add(StorageDescriptionChanged(description: value)),
                    decoration: InputDecoration(
                      labelText: '备注',
                    ),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(200),
                    ],
                    focusNode: _descriptionFocusNode,
                  ),
                  RaisedButton(
                    onPressed: state.isFormValid ? _onSubmitPressed : null,
                    child: Text('提交'),
                  ),
                  BlocBuilder<StorageEditBloc, StorageEditState>(
                    builder: (context, state) {
                      if (state is StorageEditInProgress) {
                        return CircularProgressIndicator();
                      }
                      return Container();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
