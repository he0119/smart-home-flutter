import 'package:material_ui/material_ui.dart';
import 'package:smarthome/app/dimens.dart';

class SettingsSection extends StatelessWidget {
  final String? title;
  final List<Widget> tiles;

  const SettingsSection({super.key, this.title, required this.tiles});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Text(
              title!,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: tiles.length,
          itemBuilder: (context, index) {
            return tiles[index];
          },
        ),
      ],
    );
  }
}
