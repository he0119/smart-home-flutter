import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_treeview/flutter_treeview.dart';
import 'package:smarthome/storage/storage.dart';

List<Node> childrenNode(String? key, List<Storage> storages) {
  final children = storages.where((storage) => storage.parent?.id == key);
  if (children.isNotEmpty) {
    final childNodes = children
        .map(
          (child) => Node(
            key: child.id,
            label: child.name,
            children: childrenNode(child.id, storages),
          ),
        )
        .toList();
    return childNodes;
  }
  return [];
}

class StorageDialog extends StatefulWidget {
  final List<Storage> storages;

  const StorageDialog({
    Key? key,
    required this.storages,
  }) : super(key: key);

  @override
  State<StorageDialog> createState() => _StorageDialogState();
}

class _StorageDialogState extends State<StorageDialog> {
  late List<Node> _nodes;
  late TreeViewController _treeViewController;

  @override
  void initState() {
    _nodes = childrenNode(null, widget.storages);
    _treeViewController = TreeViewController(children: _nodes);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: TreeView(
        controller: _treeViewController,
        allowParentSelect: true,
        onNodeTap: (node) {
          final storage =
              widget.storages.firstWhere((storage) => storage.id == node);
          Navigator.of(context).pop(storage);
        },
      ),
    );
  }
}

class StorageFormField extends FormField<Storage> {
  StorageFormField({
    // From super
    Key? key,
    FormFieldSetter<Storage>? onSaved,
    FormFieldValidator<Storage>? validator,
    Storage? initialValue,
    AutovalidateMode? autovalidateMode,
    bool enabled = true,
    String? label,
    this.onChanged,
  }) : super(
          key: key,
          autovalidateMode: autovalidateMode,
          initialValue: initialValue,
          enabled: enabled,
          validator: validator,
          onSaved: onSaved,
          builder: (field) {
            final _StorageFieldState state = field as _StorageFieldState;
            return TextField(
              focusNode: state._focusNode,
              controller: state._controller,
              decoration: InputDecoration(
                label: label != null ? Text(label) : null,
                errorText: state.errorText,
              ).applyDefaults(Theme.of(field.context).inputDecorationTheme),
              readOnly: true,
            );
          },
        );

  final void Function(Storage? value)? onChanged;

  @override
  _StorageFieldState createState() => _StorageFieldState();
}

class _StorageFieldState extends FormFieldState<Storage> {
  bool isShowingDialog = false;
  bool hadFocus = false;
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  StorageFormField get widget => super.widget as StorageFormField;

  bool get hasFocus => _focusNode.hasFocus;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue?.name);
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _focusNode.removeListener(_handleFocusChanged);
    super.dispose();
  }

  @override
  void didChange(Storage? value) {
    if (widget.onChanged != null) widget.onChanged!(value);
    super.didChange(value);
  }

  void _handleFocusChanged() {
    if (hasFocus && !hadFocus) {
      hadFocus = hasFocus;
      _hideKeyboard();
      requestUpdate();
    } else {
      hadFocus = hasFocus;
    }
  }

  void _hideKeyboard() {
    Future.microtask(() => FocusScope.of(context).requestFocus(FocusNode()));
  }

  Future<void> requestUpdate() async {
    if (!isShowingDialog) {
      isShowingDialog = true;
      final storages = await RepositoryProvider.of<StorageRepository>(context)
          .storages(key: '');
      final newValue = await showDialog<Storage>(
        context: context,
        builder: (context) {
          return StorageDialog(
            storages: storages,
          );
        },
      );
      isShowingDialog = false;
      if (newValue != null) {
        didChange(newValue);
        _controller.text = newValue.name;
      }
    }
  }
}
