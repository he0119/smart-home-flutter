import 'package:animated_tree_view/tree_view/tree_node.dart';
import 'package:animated_tree_view/tree_view/tree_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthome/storage/storage.dart';
import 'package:smarthome/utils/constants.dart';

List<TreeNode<Storage>> childrenNode(String? key, List<Storage> storages) {
  final children = storages.where(
    (storage) => (storage.parent?.id ?? homeStorage.id) == key,
  );
  if (children.isNotEmpty) {
    final childNodes = children
        .map(
          (child) =>
              TreeNode<Storage>(key: child.id, data: child)
                ..addAll(childrenNode(child.id, storages)),
        )
        .toList();
    return childNodes;
  }
  return [];
}

TreeNode<Storage> generateNodes(List<Storage> storages) {
  // 家应该最为根节点，这样才能选中
  final homeNode = TreeNode<Storage>(key: homeStorage.id, data: homeStorage)
    ..addAll(childrenNode(homeStorage.id, storages));

  return homeNode;
}

/// 查找 storage 的所有父节点
List<Storage> findParents(Storage storage, List<Storage> storages) {
  final parents = <Storage>[];
  var current = storage;
  while (current.parent != null) {
    final parent = storages.firstWhere(
      (element) => element.id == current.parent!.id,
    );
    parents.add(parent);
    current = parent;
  }
  return parents;
}

class StorageDialog extends StatefulWidget {
  final Storage? storage;
  final List<Storage> storages;

  const StorageDialog({super.key, this.storage, required this.storages});

  @override
  State<StorageDialog> createState() => _StorageDialogState();
}

class _StorageDialogState extends State<StorageDialog> {
  String _searchTerm = '';
  late TreeNode<Storage> _rootNode;

  @override
  void initState() {
    super.initState();
    _rootNode = generateNodes(widget.storages);
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
              final filteredStorages = widget.storages
                  .where((element) => element.name.contains(value))
                  .toList();

              final newStorages = filteredStorages.toSet();
              for (var storage in filteredStorages) {
                final parents = findParents(storage, widget.storages);
                newStorages.addAll(parents);
              }

              setState(() {
                _searchTerm = value;
                _rootNode = generateNodes(newStorages.toList());
              });
            },
          ),
          Expanded(
            child: TreeView.simple(
              tree: _rootNode,
              key: ValueKey(_searchTerm),
              onTreeReady: (controller) {
                controller.expandAllChildren(_rootNode);
              },
              builder: (context, node) => Card(
                color: node.key == widget.storage?.id
                    ? Theme.of(context).highlightColor
                    : null,
                child: ListTile(
                  title: Text(node.data?.name ?? ''),
                  // 不能选择当前存储位置
                  leading: node.key != widget.storage?.id
                      ? IconButton(
                          onPressed: () {
                            Navigator.of(context).pop(node.data);
                          },
                          icon: Icon(Icons.check),
                        )
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StorageFormField extends FormField<Storage> {
  StorageFormField({
    // From super
    super.key,
    super.validator,
    super.initialValue,
    super.autovalidateMode,
    super.enabled,
    InputDecoration? decoration = const InputDecoration(),
    this.onChanged,
  }) : super(
         builder: (field) {
           final _StorageFieldState state = field as _StorageFieldState;
           final InputDecoration effectiveDecoration =
               (decoration ?? const InputDecoration()).applyDefaults(
                 Theme.of(field.context).inputDecorationTheme,
               );
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
    // ignore: use_build_context_synchronously
    Future.microtask(() => FocusScope.of(context).requestFocus(FocusNode()));
  }

  Future<void> requestUpdate() async {
    if (!isShowingDialog) {
      isShowingDialog = true;
      final storages = await RepositoryProvider.of<StorageRepository>(
        context,
      ).storages(key: '', cache: false);
      if (context.mounted) {
        final newValue = await showDialog<Storage>(
          // TODO: 这里也不清楚，明明已经检查过 mounted 了。
          // ignore: use_build_context_synchronously
          context: context,
          builder: (context) {
            return StorageDialog(storage: value, storages: storages);
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
