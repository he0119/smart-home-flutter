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
