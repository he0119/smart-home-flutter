import 'package:material_ui/material_ui.dart';
import 'package:smarthome/widgets/state_views.dart';

class CenterMessage extends StatelessWidget {
  final String message;

  const CenterMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return EmptyState(title: message);
  }
}

class SliverCenterMessage extends StatelessWidget {
  final String message;

  const SliverCenterMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: CenterMessage(message: message),
    );
  }
}
