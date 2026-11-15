import 'package:material_ui/material_ui.dart';
import 'package:flutter/widget_previews.dart';
import 'package:smarthome/app/dimens.dart';
import 'package:smarthome/widgets/preview_frame.dart';

/// 高亮指定文字
class SubstringHighlight extends StatelessWidget {
  /// 文本
  final String text;

  /// 高亮文本
  final String term;

  /// 最多几行，副标题一般限一行，避免把行撑高
  final int? maxLines;
  final TextOverflow? overflow;

  const SubstringHighlight({
    super.key,
    required this.text,
    required this.term,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = DefaultTextStyle.of(context).style;
    // 高亮用主色加粗，红色留给错误状态
    final textHighlightStyle = textStyle.merge(
      TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
    );

    if (term.isEmpty) {
      return Text(
        text,
        style: textStyle,
        maxLines: maxLines,
        overflow: overflow,
      );
    } else {
      final termLC = term.toLowerCase();

      final children = <InlineSpan>[];
      final spanList = text.toLowerCase().split(termLC);
      var i = 0;
      for (var v in spanList) {
        if (v.isNotEmpty) {
          children.add(
            TextSpan(text: text.substring(i, i + v.length), style: textStyle),
          );
          i += v.length;
        }
        if (i < text.length) {
          children.add(
            TextSpan(
              text: text.substring(i, i + term.length),
              style: textHighlightStyle,
            ),
          );
          i += term.length;
        }
      }
      return RichText(
        text: TextSpan(children: children),
        maxLines: maxLines,
        overflow: overflow ?? TextOverflow.clip,
      );
    }
  }
}

/// 开发时在 IDE 里直接看效果，不依赖后端数据。
@Preview(
  name: 'SubstringHighlight',
  group: previewGroupWidgets,
  size: Size(400, 200),
)
Widget substringHighlightPreview() => PreviewFrame(
  width: 400,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      const SubstringHighlight(text: '阳台储物柜里的电动螺丝刀', term: '储物'),
      const SizedBox(height: AppSpacing.md),
      // 关键字没命中时原样显示，不应该吞掉文字
      const SubstringHighlight(text: '没有命中关键字时原样显示', term: '找不到'),
    ],
  ),
);
