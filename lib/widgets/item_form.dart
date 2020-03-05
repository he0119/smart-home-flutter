import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/storage/item_form_bloc.dart';
import 'package:smart_home/models/models.dart';

class ItemForm extends StatefulWidget {
  final Item item;
  ItemForm({@required this.item});

  @override
  State<ItemForm> createState() => _ItemFormState();
}

class _ItemFormState extends State<ItemForm> {
  final _formKey = GlobalKey<FormState>();
  ItemFormBloc _itemFormBloc;

  FocusNode _nameFocusNode;
  FocusNode _numberFocusNode;
  FocusNode _descriptionFocusNode;
  FocusNode _priceFocusNode;

  @override
  void initState() {
    super.initState();
    _itemFormBloc = BlocProvider.of<ItemFormBloc>(context);
    _itemFormBloc.add(NameChanged(name: widget.item.name));
    _itemFormBloc.add(NumberChanged(number: widget.item.number.toString()));
    _itemFormBloc.add(PriceChanged(price: widget.item.price.toString()));
    _itemFormBloc.add(DescriptionChanged(description: widget.item.description));
    _itemFormBloc.add(
      ExpirationDateChanged(expirationDate: widget.item.expirationDate),
    );

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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ItemFormBloc, ItemFormState>(
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                initialValue: widget.item.name,
                onChanged: (value) =>
                    _itemFormBloc.add(NameChanged(name: value)),
                decoration: InputDecoration(
                  labelText: '名称',
                ),
                textAlign: TextAlign.center,
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
                textAlign: TextAlign.center,
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
              TextFormField(
                initialValue: widget.item.description,
                onChanged: (value) =>
                    _itemFormBloc.add(DescriptionChanged(description: value)),
                decoration: InputDecoration(
                  labelText: '备注',
                ),
                textAlign: TextAlign.center,
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
                textAlign: TextAlign.center,
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
            ],
          ),
        );
      },
    );
  }
}
