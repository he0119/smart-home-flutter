import 'package:material_ui/material_ui.dart';

class MyChoiceChip extends StatelessWidget {
  final Widget label;
  final bool selected;
  final void Function(bool)? onSelected;

  const MyChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: ChoiceChip(
        label: label,
        selected: selected,
        onSelected: onSelected,
      ),
    );
  }
}

/// 多选筛选 chip。和 [MyChoiceChip] 的区别是语义：多个筛选条件可以同时生效，
/// 读屏不会把它念成同一组单选。
class MyFilterChip extends StatelessWidget {
  final Widget label;
  final bool selected;
  final void Function(bool)? onSelected;

  const MyFilterChip({
    super.key,
    required this.label,
    required this.selected,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
      child: FilterChip(
        label: label,
        selected: selected,
        onSelected: onSelected,
      ),
    );
  }
}
