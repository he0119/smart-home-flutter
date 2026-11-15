import 'package:material_ui/material_ui.dart';
import 'package:flutter/widget_previews.dart';
import 'package:smarthome/widgets/preview_frame.dart';

class BottomLoader extends StatelessWidget {
  const BottomLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '正在加载更多',
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }
}

/// 开发时在 IDE 里直接看效果，不依赖后端数据。
@Preview(name: 'BottomLoader', group: previewGroupWidgets, size: Size(360, 120))
Widget bottomLoaderPreview() =>
    const PreviewFrame(width: 360, child: BottomLoader());
