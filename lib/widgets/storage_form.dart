import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/blocs/storage/storage_form_bloc.dart';
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
      _storageFormBloc.add(NameChanged(name: widget.storage.name));
      _storageFormBloc.add(ParentChanged(parent: widget.storage.parent?.id));
      _storageFormBloc
          .add(DescriptionChanged(description: widget.storage.description));
    } else {
      _storageFormBloc.add(NameChanged(name: ''));
      _storageFormBloc.add(ParentChanged(parent: widget.storageId));
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
      _storageFormBloc
          .add(FormSubmitted(isEditing: true, id: widget.storage.id));
    } else {
      _storageFormBloc.add(FormSubmitted(isEditing: false));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StorageFormBloc, StorageFormState>(
      listener: (context, state) {
        if (state.formSubmittedSuccessfully) {
          if (widget.isEditing) {
            if (widget.storage.parent != null) {
              BlocProvider.of<StorageBloc>(context)
                  .add(StorageRefreshStorageDetail(widget.storage.parent.id));
            } else {
              BlocProvider.of<StorageBloc>(context).add(StorageRefreshRoot());
            }
          } else {
            if (widget.storageId != null) {
              BlocProvider.of<StorageBloc>(context)
                  .add(StorageRefreshStorageDetail(widget.storageId));
            } else {
              BlocProvider.of<StorageBloc>(context).add(StorageRefreshRoot());
            }
          }
          BlocProvider.of<StorageBloc>(context).add(StorageRefreshStorages());
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        return Form(
          child: Column(
            children: <Widget>[
              TextFormField(
                initialValue: widget.isEditing ? widget.storage.name : '',
                onChanged: (value) =>
                    _storageFormBloc.add(NameChanged(name: value)),
                decoration: InputDecoration(
                  labelText: '名称',
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(200),
                ],
                autovalidate: true,
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
                  _storageFormBloc.add(ParentChanged(parent: value));
                },
              ),
              TextFormField(
                initialValue:
                    widget.isEditing ? widget.storage.description : '',
                onChanged: (value) => _storageFormBloc
                    .add(DescriptionChanged(description: value)),
                decoration: InputDecoration(
                  labelText: '备注',
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(200),
                ],
                textInputAction: TextInputAction.next,
                focusNode: _descriptionFocusNode,
              ),
              RaisedButton(
                onPressed: state.isFormValid ? _onSubmitPressed : null,
                child: Text('提交'),
              ),
            ],
          ),
        );
      },
    );
  }
}
