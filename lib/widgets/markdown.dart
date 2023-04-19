import 'package:flutter/material.dart';
import 'package:flutter_markdown_selectionarea/flutter_markdown.dart';
import 'package:smarthome/utils/launch_url.dart';

class MyMarkdownBody extends StatelessWidget {
  final String data;
  const MyMarkdownBody({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: data,
      onTapLink: (text, href, title) {
        if (href != null) {
          launchUrl(href);
        }
      },
    );
  }
}
