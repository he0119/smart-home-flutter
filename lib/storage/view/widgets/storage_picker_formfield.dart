import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_treeview/flutter_treeview.dart';
import 'package:smarthome/storage/storage.dart';
import 'package:smarthome/utils/constants.dart';
import 'package:smarthome/widgets/substring_highlight.dart';

List<Node> childrenNode(String? key, List<Storage> storages) {
  final children =
      storages.where((storage) => (storage.parent?.id ?? '') == key);
  if (children.isNotEmpty) {
    final childNodes = children
        .map(
          (child) => Node(
            key: child.id,
            label: child.name,
            expanded: true,
            children: childrenNode(child.id, storages),
          ),
        )
        .toList();
    return childNodes;
  }
  return [];
}

List<Node> generateNodes(List<Storage> storages) {
  // 家应该最为根节点，这样才能选中
  return [
    Node(
      key: '',
      label: '家',
      expanded: true,
      children: childrenNode('', storages),
    )
  ];
}

class StorageDialog extends StatefulWidget {
  final Storage? storage;
  final List<Storage> storages;

  const StorageDialog({
    Key? key,
    this.storage,
    required this.storages,
  }) : super(key: key);

  @override
  State<StorageDialog> createState() => _StorageDialogState();
}

class _StorageDialogState extends State<StorageDialog> {
  String _searchTerm = '';
  late TreeViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TreeViewController(
      children: generateNodes(widget.storages),
      selectedKey: widget.storage?.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: '搜索',
              contentPadding: EdgeInsets.fromLTRB(8, 0, 0, 0),
            ),
            onChanged: (value) async {
              final newStorages = widget.storages
                  .where((element) => element.name.contains(value))
                  .toList();
              setState(() {
                _searchTerm = value;
                _controller = TreeViewController(
                  children: generateNodes(newStorages),
                  selectedKey: widget.storage?.id,
                );
              });
            },
          ),
          Expanded(
            child: TreeView(
              key: ValueKey(_searchTerm),
              controller: _controller,
              shrinkWrap: true,
              nodeBuilder: (BuildContext context, Node node) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  child:
                      SubstringHighlight(text: node.label, term: _searchTerm),
                );
              },
              theme: TreeViewTheme(
                colorScheme: Theme.of(context).colorScheme,
              ),
              allowParentSelect: true,
              onNodeTap: (node) {
                // 针对家做特殊处理，家应该为一个 id 为 '' 的 storage
                Storage storage;
                if (node == '') {
                  storage = homeStorage;
                } else {
                  storage = widget.storages
                      .firstWhere((storage) => storage.id == node);
                }
                Navigator.of(context).pop(storage);
              },
            ),
          )
        ],
      ),
    );
  }
}

class StorageFormField extends FormField<Storage> {
  StorageFormField({
    // From super
    Key? key,
    FormFieldValidator<Storage>? validator,
    Storage? initialValue,
    AutovalidateMode? autovalidateMode,
    bool enabled = true,
    InputDecoration? decoration = const InputDecoration(),
    this.onChanged,
  }) : super(
          key: key,
          autovalidateMode: autovalidateMode,
          initialValue: initialValue,
          enabled: enabled,
          validator: validator,
          builder: (field) {
            final _StorageFieldState state = field as _StorageFieldState;
            final InputDecoration effectiveDecoration = (decoration ??
                    const InputDecoration())
                .applyDefaults(Theme.of(field.context).inputDecorationTheme);
            return TextField(
              focusNode: state._focusNode,
              controller: state._controller,
              decoration: effectiveDecoration.copyWith(
                errorText: state.errorText,
                suffixIcon: state.shouldShowClearIcon(effectiveDecoration)
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: state.clear,
                      )
                    : null,
              ),
              readOnly: true,
            );
          },
        );

  final void Function(Storage? value)? onChanged;

  @override
  FormFieldState<Storage> createState() => _StorageFieldState();
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
    _focusNode.removeListener(_handleFocusChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void reset() {
    super.reset();
    _controller.text = widget.initialValue?.name ?? '';
    didChange(widget.initialValue);
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
          .storages(key: '', cache: false);
      final newValue = await showDialog<Storage>(
        context: context,
        builder: (context) {
          return StorageDialog(
            storage: value,
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

  void clear() async {
    _hideKeyboard();
    setState(() {
      _controller.clear();
      didChange(null);
    });
  }

  bool shouldShowClearIcon([InputDecoration? decoration]) =>
      (_controller.text != '' || hasFocus) && decoration?.suffixIcon == null;
}
