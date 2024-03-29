import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthome/storage/bloc/blocs.dart';
import 'package:smarthome/storage/model/models.dart';
import 'package:smarthome/storage/view/widgets/storage_picker_formfield.dart';
import 'package:smarthome/utils/constants.dart';
import 'package:smarthome/utils/date_format_extension.dart';
import 'package:smarthome/utils/show_snack_bar.dart';
import 'package:smarthome/widgets/home_page.dart';
import 'package:smarthome/widgets/rounded_raised_button.dart';

class ItemEditPage extends StatefulWidget {
  /// 是否为编辑模式
  final bool isEditing;

  /// 提供需要编辑的物品
  final Item? item;

  /// 提供需要提供要添加到的位置
  final Storage? storage;

  const ItemEditPage({
    super.key,
    required this.isEditing,
    this.item,
    this.storage,
  })  : assert(item != null || !isEditing);

  @override
  State<ItemEditPage> createState() => _ItemEditPageState();
}

class _ItemEditPageState extends State<ItemEditPage> {
  String? storageId;
  DateTime? expiredAt;
  late TextEditingController _nameController;
  late TextEditingController _numberController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late FocusNode _nameFocusNode;
  late FocusNode _numberFocusNode;
  late FocusNode _descriptionFocusNode;
  late FocusNode _priceFocusNode;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return MySliverScaffold(
      title: widget.isEditing
          ? Text('编辑 ${widget.item!.name}')
          : const Text('添加物品'),
      sliver: BlocListener<ItemEditBloc, ItemEditState>(
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
          if (state is ItemEditFailure) {
            showErrorSnackBar(state.message);
          }
          // 物品添加和修改成功过后自动返回物品详情界面
          if (state is ItemAddSuccess || state is ItemUpdateSuccess) {
            Navigator.of(context).pop(true);
          }
        },
        child: SliverFillRemaining(
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: BlocBuilder<ItemEditBloc, ItemEditState>(
              builder: (context, state) => Form(
                key: _formKey,
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
                            context, _nameFocusNode, _numberFocusNode);
                      },
                    ),
                    TextFormField(
                      controller: _numberController,
                      decoration: const InputDecoration(
                        labelText: '数量',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value!.isEmpty) {
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
                    StorageFormField(
                      decoration: const InputDecoration(
                        labelText: '属于',
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onChanged: (Storage? value) {
                        if (value != null) {
                          storageId = value.id;
                        }
                      },
                      initialValue: widget.isEditing
                          ? widget.item!.storage
                          : widget.storage,
                      validator: (value) {
                        if (value == null) {
                          return '请选择一个存放位置';
                        } else if (value.id == homeStorage.id) {
                          return '家不能作为存放位置';
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
                      textInputAction: TextInputAction.next,
                      focusNode: _descriptionFocusNode,
                      onFieldSubmitted: (_) {
                        _fieldFocusChange(
                            context, _descriptionFocusNode, _priceFocusNode);
                      },
                    ),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: '价格',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[0-9.]'))
                      ],
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value!.isEmpty) return null;
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
                        if (date != null && context.mounted) {
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
                          ? widget.item!.expiredAt?.toLocal()
                          : null,
                      decoration: const InputDecoration(
                        labelText: '有效期至',
                      ),
                      onChanged: (value) {
                        expiredAt = value;
                      },
                    ),
                    RoundedRaisedButton(
                      onPressed: (state is! ItemEditInProgress)
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
      ),
    );
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _numberFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _priceFocusNode.dispose();
    _nameController.dispose();
    _numberController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    if (widget.isEditing) {
      _nameController = TextEditingController(text: widget.item!.name);
      _numberController =
          TextEditingController(text: widget.item!.number.toString());
      _priceController =
          TextEditingController(text: widget.item!.price?.toString());
      _descriptionController =
          TextEditingController(text: widget.item!.description);
      storageId = widget.item!.storage?.id;
      expiredAt = widget.item!.expiredAt;
    } else {
      _nameController = TextEditingController();
      _numberController = TextEditingController(text: '1');
      _descriptionController = TextEditingController();
      _priceController = TextEditingController();
      storageId = widget.storage?.id;
    }

    _nameFocusNode = FocusNode();
    _numberFocusNode = FocusNode();
    _descriptionFocusNode = FocusNode();
    _priceFocusNode = FocusNode();

    super.initState();
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode? nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  void _onSubmitPressed() {
    double? price;
    if (_priceController.text != '') {
      price = double.parse(_priceController.text);
    }

    if (widget.isEditing) {
      BlocProvider.of<ItemEditBloc>(context).add(ItemUpdated(
        id: widget.item!.id,
        name: _nameController.text,
        number: int.parse(_numberController.text),
        storageId: storageId,
        oldStorageId: widget.item!.id,
        description: _descriptionController.text,
        price: price,
        expiredAt: expiredAt?.toUtc(),
      ));
    } else {
      BlocProvider.of<ItemEditBloc>(context).add(ItemAdded(
        name: _nameController.text,
        number: int.parse(_numberController.text),
        storageId: storageId,
        description: _descriptionController.text,
        price: price,
        expiredAt: expiredAt?.toUtc(),
      ));
    }
  }
}
