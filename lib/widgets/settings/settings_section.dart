import 'package:material_ui/material_ui.dart';
import 'package:smarthome/widgets/list_rows.dart';

class SettingsSection extends StatelessWidget {
  final String? title;
  final List<Widget> tiles;

  const SettingsSection({super.key, this.title, required this.tiles});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) SectionHeader(title: title!),
        // 直接铺开，不需要套一层不能滚动的 ListView
        ...tiles,
      ],
    );
  }
}
