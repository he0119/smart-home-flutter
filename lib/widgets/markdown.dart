import 'package:material_ui/material_ui.dart';
import 'package:flutter_markdown_selectionarea/flutter_markdown.dart';
import 'package:smarthome/utils/launch_url.dart';
import 'package:smarthome/widgets/app_preview.dart';
import 'package:smarthome/widgets/preview_frame.dart';

class MyMarkdownBody extends StatelessWidget {
  final String data;
  const MyMarkdownBody({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: MarkdownBody(
        data: data,
        onTapLink: (text, href, title) {
          if (href != null) {
            launchUrl(href);
          }
        },
      ),
    );
  }
}

/// 开发时在 IDE 里直接看效果，不依赖后端数据。
@AppPreview(
  name: 'MyMarkdownBody',
  group: previewGroupWidgets,
  size: Size(480, 520),
)
Widget myMarkdownBodyPreview() => const PreviewFrame(
  width: 480,
  child: MyMarkdownBody(
    data: '''
## 标题

正文里可以有 **加粗**、*斜体* 和 [链接](https://example.com)。

- 列表第一项
- 列表第二项

> 引用一段话。
''',
  ),
);
