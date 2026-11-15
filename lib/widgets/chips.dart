import 'package:material_ui/material_ui.dart';
import 'package:flutter/widget_previews.dart';
import 'package:smarthome/app/dimens.dart';
import 'package:smarthome/widgets/preview_frame.dart';

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

/// 开发时在 IDE 里直接看效果，不依赖后端数据。
@Preview(name: 'MyChoiceChip', group: previewGroupWidgets, size: Size(400, 120))
Widget myChoiceChipPreview() => PreviewFrame(
  child: Wrap(
    spacing: AppSpacing.sm,
    children: <Widget>[
      MyChoiceChip(
        label: const Text('已选中'),
        selected: true,
        onSelected: (_) {},
      ),
      MyChoiceChip(
        label: const Text('未选中'),
        selected: false,
        onSelected: (_) {},
      ),
    ],
  ),
);

@Preview(name: 'MyFilterChip', group: previewGroupWidgets, size: Size(400, 120))
Widget myFilterChipPreview() => PreviewFrame(
  child: Wrap(
    spacing: AppSpacing.sm,
    children: <Widget>[
      MyFilterChip(
        label: const Text('已选中'),
        selected: true,
        onSelected: (_) {},
      ),
      MyFilterChip(
        label: const Text('未选中'),
        selected: false,
        onSelected: (_) {},
      ),
    ],
  ),
);
