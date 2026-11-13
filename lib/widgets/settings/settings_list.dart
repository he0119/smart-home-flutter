import 'package:material_ui/material_ui.dart';

class SettingsList extends StatelessWidget {
  final List<Widget> sections;

  const SettingsList({super.key, required this.sections});

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        return sections[index];
      }, childCount: sections.length),
    );
  }
}
