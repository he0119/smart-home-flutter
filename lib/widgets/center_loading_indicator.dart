import 'package:material_ui/material_ui.dart';
import 'package:smarthome/widgets/state_views.dart';
import 'package:flutter/widget_previews.dart';
import 'package:smarthome/widgets/preview_frame.dart';

class CenterLoadingIndicator extends StatelessWidget {
  const CenterLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoadingState();
  }
}

class SliverCenterLoadingIndicator extends StatelessWidget {
  const SliverCenterLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const SliverFillRemaining(
      hasScrollBody: false,
      child: CenterLoadingIndicator(),
    );
  }
}

/// 开发时在 IDE 里直接看效果，不依赖后端数据。
@Preview(
  name: 'CenterLoadingIndicator',
  group: previewGroupWidgets,
  size: Size(360, 240),
)
Widget centerLoadingIndicatorPreview() =>
    const PreviewFrame(width: 360, child: CenterLoadingIndicator());

@Preview(
  name: 'SliverCenterLoadingIndicator',
  group: previewGroupWidgets,
  size: Size(360, 240),
)
Widget sliverCenterLoadingIndicatorPreview() => const PreviewFrame(
  width: 360,
  padding: EdgeInsets.zero,
  child: CustomScrollView(slivers: <Widget>[SliverCenterLoadingIndicator()]),
);
