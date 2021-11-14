import 'package:flutter/material.dart';

class SettingsList extends StatelessWidget {
  final List<Widget> sections;

  const SettingsList({
    Key? key,
    required this.sections,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: sections.length,
      itemBuilder: (context, index) {
        return Card(child: sections[index]);
      },
    );
  }
}
