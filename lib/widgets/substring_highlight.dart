import 'package:material_ui/material_ui.dart';

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
