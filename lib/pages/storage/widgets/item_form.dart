import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:smart_home/blocs/storage/blocs.dart';
import 'package:smart_home/models/models.dart';

class ItemForm extends StatefulWidget {
  final bool isEditing;
  final String storageId;
  final Item item;

  ItemForm({
    @required this.isEditing,
    this.item,
    this.storageId,
  });

  @override
  State<ItemForm> createState() => _ItemFormState();
}

class _ItemFormState extends State<ItemForm> {
  ItemFormBloc _itemFormBloc;

  final format = DateFormat.yMMMd().add_jm();

  FocusNode _nameFocusNode;
  FocusNode _numberFocusNode;
  FocusNode _descriptionFocusNode;
  FocusNode _priceFocusNode;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ItemFormBloc, ItemFormState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Form(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    initialValue: widget.isEditing ? widget.item.name : '',
                    onChanged: (value) =>
                        _itemFormBloc.add(ItemNameChanged(name: value)),
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
                          context, _nameFocusNode, _numberFocusNode);
                    },
                  ),
                  TextFormField(
                    initialValue:
                        widget.isEditing ? widget.item.number.toString() : '1',
                    onChanged: (value) =>
                        _itemFormBloc.add(ItemNumberChanged(number: value)),
                    decoration: InputDecoration(
                      labelText: '数量',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (_) {
                      return state.isNumberValid ? null : '数量不能为空';
                    },
                    textInputAction: TextInputAction.next,
                    focusNode: _numberFocusNode,
                    onFieldSubmitted: (_) {
                      _fieldFocusChange(
                          context, _numberFocusNode, _descriptionFocusNode);
                    },
                  ),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: '属于',
                    ),
                    value: widget.isEditing ? state.storage : widget.storageId,
                    items: state.listofStorages
                        .map((e) => DropdownMenuItem(
                              value: e.id,
                              child: Text(e.name),
                            ))
                        .toList(),
                    onChanged: (value) {
                      _itemFormBloc.add(ItemStorageChanged(storage: value));
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (_) {
                      return state.isStorageValid ? null : '名称不能为空';
                    },
                  ),
                  TextFormField(
                    initialValue:
                        widget.isEditing ? widget.item.description : '',
                    onChanged: (value) => _itemFormBloc
                        .add(ItemDescriptionChanged(description: value)),
                    decoration: InputDecoration(
                      labelText: '备注',
                    ),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(200),
                    ],
                    textInputAction: TextInputAction.next,
                    focusNode: _descriptionFocusNode,
                    onFieldSubmitted: (_) {
                      _fieldFocusChange(
                          context, _descriptionFocusNode, _priceFocusNode);
                    },
                  ),
                  TextFormField(
                    initialValue:
                        widget.isEditing ? widget.item.price?.toString() : '',
                    onChanged: (value) =>
                        _itemFormBloc.add(ItemPriceChanged(price: value)),
                    decoration: InputDecoration(
                      labelText: '价格',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[0-9\.]'))
                    ],
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (_) {
                      return state.isPriceValid ? null : '价格最多只能有两位小数且不超过一亿';
                    },
                    focusNode: _priceFocusNode,
                  ),
                  DateTimeField(
                    format: format,
                    onShowPicker: (context, currentValue) async {
                      final date = await showDatePicker(
                          context: context,
                          firstDate: DateTime(1900),
                          initialDate: currentValue ?? DateTime.now(),
                          lastDate: DateTime(2100));
                      if (date != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(
                              currentValue ?? DateTime.now()),
                        );
                        return DateTimeField.combine(date, time);
                      } else {
                        return currentValue;
                      }
                    },
                    initialValue: widget.isEditing
                        ? widget.item.expirationDate?.toLocal()
                        : null,
                    decoration: InputDecoration(
                      labelText: '有效期至',
                    ),
                    onChanged: (value) {
                      _itemFormBloc.add(
                          ItemExpirationDateChanged(expirationDate: value));
                    },
                  ),
                  RaisedButton(
                    onPressed: state.isFormValid ? _onSubmitPressed : null,
                    child: Text('提交'),
                  ),
                  BlocBuilder<ItemEditBloc, ItemEditState>(
                    builder: (context, state) {
                      if (state is ItemEditInProgress) {
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

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    _nameFocusNode.dispose();
    _numberFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _priceFocusNode.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _itemFormBloc = BlocProvider.of<ItemFormBloc>(context);
    _itemFormBloc.add(ItemFormStarted());
    if (widget.isEditing) {
      _itemFormBloc.add(ItemNameChanged(name: widget.item.name));
      _itemFormBloc
          .add(ItemNumberChanged(number: widget.item.number.toString()));
      _itemFormBloc.add(ItemStorageChanged(storage: widget.item.storage.id));
      _itemFormBloc
          .add(ItemPriceChanged(price: widget.item.price?.toString() ?? ''));
      _itemFormBloc
          .add(ItemDescriptionChanged(description: widget.item.description));
      _itemFormBloc.add(
        ItemExpirationDateChanged(expirationDate: widget.item.expirationDate),
      );
    } else {
      _itemFormBloc.add(ItemNameChanged(name: ''));
      _itemFormBloc.add(ItemStorageChanged(storage: widget.storageId));
      _itemFormBloc.add(ItemNumberChanged(number: '1'));
    }

    _nameFocusNode = FocusNode();
    _numberFocusNode = FocusNode();
    _descriptionFocusNode = FocusNode();
    _priceFocusNode = FocusNode();
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  void _onSubmitPressed() {
    if (widget.isEditing) {
      _itemFormBloc.add(ItemFormSubmitted(
        isEditing: true,
        id: widget.item.id,
        oldStorageId: widget.item.storage.id,
      ));
    } else {
      _itemFormBloc.add(ItemFormSubmitted(isEditing: false));
    }
  }
}
