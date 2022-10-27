import 'package:flutter/material.dart';

class SettingsList extends StatelessWidget {
  final List<Widget> sections;

  const SettingsList({
    Key? key,
    required this.sections,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        return sections[index];
      }, childCount: sections.length),
    );
  }
}
