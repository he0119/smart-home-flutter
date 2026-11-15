import 'package:material_ui/material_ui.dart';
import 'package:smarthome/core/router/router_extensions.dart';
import 'package:flutter/widget_previews.dart';
import 'package:smarthome/widgets/preview_frame.dart';

class SearchIconButton extends StatelessWidget {
  const SearchIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: '搜索',
      icon: const Icon(Icons.search),
      onPressed: () {
        context.goSearch();
      },
    );
  }
}

/// 开发时在 IDE 里直接看效果，不依赖后端数据。
@Preview(
  name: 'SearchIconButton',
  group: previewGroupStorage,
  size: Size(120, 80),
)
Widget searchIconButtonPreview() => const PreviewFrame(
  width: 120,
  padding: EdgeInsets.zero,
  child: Center(child: SearchIconButton()),
);
