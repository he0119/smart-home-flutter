import 'package:flutter/material.dart';

/// 高亮指定文字
class SubstringHighlight extends StatelessWidget {
  /// 文本
  final String text;

  /// 高亮文本
  final String term;

  SubstringHighlight({
    Key? key,
    required this.text,
    required this.term,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = DefaultTextStyle.of(context).style;
    // 高亮颜色为红色
    final textHighlightStyle =
        textStyle.merge(const TextStyle(color: Colors.red));

    if (term.isEmpty) {
      return Text(text, style: textStyle);
    } else {
      final termLC = term.toLowerCase();

      final children = <InlineSpan>[];
      final spanList = text.toLowerCase().split(termLC);
      var i = 0;
      for (var v in spanList) {
        if (v.isNotEmpty) {
          children.add(TextSpan(
              text: text.substring(i, i + v.length), style: textStyle));
          i += v.length;
        }
        if (i < text.length) {
          children.add(TextSpan(
              text: text.substring(i, i + term.length),
              style: textHighlightStyle));
          i += term.length;
        }
      }
      return RichText(text: TextSpan(children: children));
    }
  }
}
