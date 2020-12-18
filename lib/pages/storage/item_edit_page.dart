import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/storage/blocs.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/models/storage.dart';
import 'package:smart_home/widgets/rounded_raised_button.dart';
import 'package:smart_home/utils/date_format_extension.dart';
import 'package:smart_home/widgets/show_snack_bar.dart';

class ItemEditPage extends StatefulWidget {
  final bool isEditing;
  final Item item;
  final String storageId;
  final List<Storage> listofStorages;

  const ItemEditPage({
    Key key,
    @required this.isEditing,
    @required this.listofStorages,
    this.item,
    this.storageId,
  }) : super(key: key);

  @override
  _ItemEditPageState createState() => _ItemEditPageState();
}

class _ItemEditPageState extends State<ItemEditPage> {
  String storageId;
  DateTime expirationDate;
  TextEditingController _nameController;
  TextEditingController _numberController;
  TextEditingController _descriptionController;
  TextEditingController _priceController;
  FocusNode _nameFocusNode;
  FocusNode _numberFocusNode;
  FocusNode _descriptionFocusNode;
  FocusNode _priceFocusNode;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.isEditing ? Text('编辑 ${widget.item.name}') : Text('添加物品'),
      ),
      body: BlocListener<ItemEditBloc, ItemEditState>(
        listener: (context, state) {
          if (state is ItemEditInProgress) {
            showInfoSnackBar('正在提交...', duration: 1);
          }
          if (state is ItemAddSuccess) {
            showInfoSnackBar('物品 ${state.item.name} 添加成功');
          }
          if (state is ItemUpdateSuccess) {
            showInfoSnackBar('物品 ${state.item.name} 修改成功');
          }
          // 物品添加和修改成功过后自动返回物品详情界面
          if (state is ItemAddSuccess || state is ItemUpdateSuccess) {
            Navigator.of(context).pop();
          }
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: BlocBuilder<ItemEditBloc, ItemEditState>(
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
                            context, _nameFocusNode, _numberFocusNode);
                      },
                    ),
                    TextFormField(
                      controller: _numberController,
                      decoration: InputDecoration(
                        labelText: '数量',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value.isEmpty) {
                          return '数量不能为空';
                        }
                        return null;
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
                      value: widget.isEditing
                          ? widget.item.storage.id
                          : widget.storageId,
                      items: widget.listofStorages
                          .map((e) => DropdownMenuItem(
                                value: e.id,
                                child: Text(e.name),
                              ))
                          .toList(),
                      onChanged: (value) {
                        storageId = value;
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
                      textInputAction: TextInputAction.next,
                      focusNode: _descriptionFocusNode,
                      onFieldSubmitted: (_) {
                        _fieldFocusChange(
                            context, _descriptionFocusNode, _priceFocusNode);
                      },
                    ),
                    TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: '价格',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[0-9\.]'))
                      ],
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value.isEmpty) return null;
                        final parts = value.split('.');
                        if (parts.length > 2) {
                          return '价格最多只能有两位小数且不超过一亿';
                        }
                        if (parts[0].length > 8) {
                          return '价格不能超过一亿';
                        }
                        if (parts.length == 2 && parts[1].length > 2) {
                          return '价格最多只能有两位小数';
                        }
                        return null;
                      },
                      focusNode: _priceFocusNode,
                    ),
                    DateTimeField(
                      format: DateTime.now().localFormat,
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
                        expirationDate = value;
                      },
                    ),
                    RoundedRaisedButton(
                      onPressed: (state is! ItemEditInProgress)
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
    );
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _numberFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _priceFocusNode.dispose();

    super.dispose();
  }

  @override
  void initState() {
    if (widget.isEditing) {
      _nameController = TextEditingController(text: widget.item.name);
      _numberController =
          TextEditingController(text: widget.item.number.toString());
      _priceController =
          TextEditingController(text: widget.item.price?.toString());
      _descriptionController =
          TextEditingController(text: widget.item.description);
      storageId = widget.item.storage.id;
      expirationDate = widget.item.expirationDate;
    } else {
      _nameController = TextEditingController();
      _numberController = TextEditingController(text: '1');
      _descriptionController = TextEditingController();
      _priceController = TextEditingController();
      storageId = widget.storageId;
    }

    _nameFocusNode = FocusNode();
    _numberFocusNode = FocusNode();
    _descriptionFocusNode = FocusNode();
    _priceFocusNode = FocusNode();

    super.initState();
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  void _onSubmitPressed() {
    double _price;
    if (_priceController.text != null && _priceController.text != '') {
      _price = double.parse(_priceController.text);
    }

    if (widget.isEditing) {
      BlocProvider.of<ItemEditBloc>(context).add(ItemUpdated(
        id: widget.item.id,
        name: _nameController.text,
        number: int.parse(_numberController.text),
        storageId: storageId,
        oldStorageId: widget.item.id,
        description: _descriptionController.text,
        price: _price,
        expirationDate: expirationDate?.toUtc(),
      ));
    } else {
      BlocProvider.of<ItemEditBloc>(context).add(ItemAdded(
        name: _nameController.text,
        number: int.parse(_numberController.text),
        storageId: storageId,
        description: _descriptionController.text,
        price: _price,
        expirationDate: expirationDate?.toUtc(),
      ));
    }
  }
}
