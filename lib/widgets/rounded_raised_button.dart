import 'package:material_ui/material_ui.dart';
import 'package:flutter/widget_previews.dart';
import 'package:smarthome/widgets/preview_frame.dart';

class RoundedRaisedButton extends StatelessWidget {
  final Widget? child;
  final Function? onPressed;

  const RoundedRaisedButton({super.key, this.child, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton(onPressed: onPressed as void Function()?, child: child);
  }
}

class SliverCenterRoundedRaisedButton extends StatelessWidget {
  final Widget? child;
  final Function? onPressed;

  const SliverCenterRoundedRaisedButton({
    super.key,
    this.child,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: RoundedRaisedButton(onPressed: onPressed, child: child),
      ),
    );
  }
}

/// 开发时在 IDE 里直接看效果，不依赖后端数据。
@Preview(name: 'RoundedRaisedButton', group: previewGroupWidgets)
Widget roundedRaisedButtonPreview() => PreviewFrame(
  width: 360,
  child: RoundedRaisedButton(onPressed: () {}, child: const Text('保存')),
);

@Preview(
  name: 'SliverCenterRoundedRaisedButton',
  group: previewGroupWidgets,
  size: Size(360, 320),
)
Widget sliverCenterRoundedRaisedButtonPreview() => PreviewFrame(
  width: 360,
  padding: EdgeInsets.zero,
  child: CustomScrollView(
    slivers: <Widget>[
      SliverCenterRoundedRaisedButton(
        onPressed: () {},
        child: const Text('保存'),
      ),
    ],
  ),
);
