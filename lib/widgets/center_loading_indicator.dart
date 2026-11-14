import 'package:material_ui/material_ui.dart';
import 'package:smarthome/widgets/state_views.dart';

class CenterLoadingIndicator extends StatelessWidget {
  const CenterLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoadingState();
  }
}

class SliverCenterLoadingIndicator extends StatelessWidget {
  const SliverCenterLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const SliverFillRemaining(
      hasScrollBody: false,
      child: CenterLoadingIndicator(),
    );
  }
}
