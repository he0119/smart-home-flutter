import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:smart_home/blocs/storage/item_form_bloc.dart';
import 'package:smart_home/models/models.dart';

class ItemForm extends StatefulWidget {
  final Item item;
  ItemForm({@required this.item});

  @override
  State<ItemForm> createState() => _ItemFormState();
}

class _ItemFormState extends State<ItemForm> {
  ItemFormBloc _itemFormBloc;

  final TextEditingController _expirationDateController =
      TextEditingController();

  FocusNode _nameFocusNode;
  FocusNode _numberFocusNode;
  FocusNode _descriptionFocusNode;
  FocusNode _priceFocusNode;

  @override
  void initState() {
    super.initState();
    _itemFormBloc = BlocProvider.of<ItemFormBloc>(context);
    _itemFormBloc.add(ItemFormStarted());
    _itemFormBloc.add(NameChanged(name: widget.item.name));
    _itemFormBloc.add(NumberChanged(number: widget.item.number.toString()));
    _itemFormBloc.add(StorageChanged(storage: widget.item.storage));
    _itemFormBloc.add(PriceChanged(price: widget.item.price?.toString()));
    _itemFormBloc.add(DescriptionChanged(description: widget.item.description));
    _itemFormBloc.add(
      ExpirationDateChanged(expirationDate: widget.item.expirationDate),
    );

    if (widget.item.expirationDate != null)
      _expirationDateController.text =
          DateFormat.yMMMd('zh').format(widget.item.expirationDate.toLocal());

    _nameFocusNode = FocusNode();
    _numberFocusNode = FocusNode();
    _descriptionFocusNode = FocusNode();
    _priceFocusNode = FocusNode();
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

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  Future _selectDate() async {
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1970),
        lastDate: DateTime(2050));
    if (picked != null) {
      _itemFormBloc.add(ExpirationDateChanged(expirationDate: picked));
      _expirationDateController.text = DateFormat.yMMMd('zh').format(picked);
    }
  }

  void _onSubmitPressed() {
    _itemFormBloc.add(FormSubmitted(id: widget.item.id));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ItemFormBloc, ItemFormState>(
      listener: (context, state) {
        if (state.formSubmittedSuccessfully) {
          Navigator.of(context).pop<Item>(state.editedItem);
        }
      },
      builder: (context, state) {
        return Form(
          child: Column(
            children: <Widget>[
              TextFormField(
                initialValue: widget.item.name,
                onChanged: (value) =>
                    _itemFormBloc.add(NameChanged(name: value)),
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
                  _fieldFocusChange(context, _nameFocusNode, _numberFocusNode);
                },
              ),
              TextFormField(
                initialValue: widget.item.number.toString(),
                onChanged: (value) =>
                    _itemFormBloc.add(NumberChanged(number: value)),
                decoration: InputDecoration(
                  labelText: '数量',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                autovalidate: true,
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
              DropdownButtonFormField<Storage>(
                decoration: InputDecoration(
                  labelText: '属于',
                ),
                value: state.storage,
                items: state.listofStorages
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.name),
                        ))
                    .toList(),
                onChanged: (value) {
                  _itemFormBloc.add(StorageChanged(storage: value));
                },
                autovalidate: true,
                validator: (_) {
                  return state.isStorageValid ? null : '名称不能为空';
                },
              ),
              TextFormField(
                initialValue: widget.item.description,
                onChanged: (value) =>
                    _itemFormBloc.add(DescriptionChanged(description: value)),
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
                initialValue: widget.item.price?.toString(),
                onChanged: (value) =>
                    _itemFormBloc.add(PriceChanged(price: value)),
                decoration: InputDecoration(
                  labelText: '价格',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  WhitelistingTextInputFormatter(RegExp('[0-9\.]'))
                ],
                autovalidate: true,
                validator: (_) {
                  return state.isPriceValid ? null : '价格最多只能有两位小数且不超过一亿';
                },
                focusNode: _priceFocusNode,
              ),
              TextFormField(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                  _selectDate();
                },
                controller: _expirationDateController,
                decoration: InputDecoration(
                  labelText: '有效期至',
                ),
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