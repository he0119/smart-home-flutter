import 'package:material_ui/material_ui.dart';

/// 单选型设置行的尾部：选中显示勾，未选中留出同样宽度的空位保持对齐。
class SelectionCheck extends StatelessWidget {
  final bool selected;

  const SelectionCheck({super.key, required this.selected});

  @override
  Widget build(BuildContext context) {
    if (!selected) {
      // 占位而不是 Icon(null)，意图更直白
      return const SizedBox(width: 24);
    }
    return Icon(Icons.check, color: Theme.of(context).colorScheme.primary);
  }
}
