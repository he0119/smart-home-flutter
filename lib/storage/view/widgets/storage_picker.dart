import 'package:flutter/material.dart';
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

// class StoragePickerPage extends StatefulWidget {
//   final List<Storage> storages;

//   const StoragePickerPage({
//     Key? key,
//     required this.storages,
//   }) : super(key: key);

//   @override
//   State<StoragePickerPage> createState() => _StoragePickerPageState();
// }

// class _StoragePickerPageState extends State<StoragePickerPage> {
//   late List<Node> _nodes;
//   late TreeViewController _treeViewController;

//   @override
//   void initState() {
//     _nodes = childrenNode(null, widget.storages);
//     _treeViewController = TreeViewController(children: _nodes);
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: TreeView(
//         controller: _treeViewController,
//         allowParentSelect: true,
//         onNodeTap: (node) {
//           final storage =
//               widget.storages.firstWhere((storage) => storage.id == node);
//           Navigator.of(context).pop(storage);
//         },
//       ),
//     );
//   }
// }

class StoragePicker extends FormField<Storage> {
  StoragePicker({
    // From super
    Key? key,
    FormFieldSetter<Storage>? onSaved,
    FormFieldValidator<Storage>? validator,
    Storage? initialValue,
    AutovalidateMode? autovalidateMode,
    bool enabled = true,
    String? label,
  }) : super(
          key: key,
          autovalidateMode: autovalidateMode,
          initialValue: initialValue,
          enabled: enabled,
          validator: validator,
          onSaved: onSaved,
          builder: (field) {
            final decoration = const InputDecoration()
                .applyDefaults(Theme.of(field.context).inputDecorationTheme);
            return TextField(
              decoration: decoration,
            );
          },
        );
}
