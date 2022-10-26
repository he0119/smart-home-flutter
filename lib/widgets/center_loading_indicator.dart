import 'package:flutter/material.dart';
import 'package:smarthome/widgets/conditional_parent_widget.dart';

class CenterLoadingIndicator extends StatelessWidget {
  final bool sliver;

  const CenterLoadingIndicator({super.key, this.sliver = true});

  @override
  Widget build(BuildContext context) {
    return ConditionalParentWidget(
      condition: sliver,
      conditionalBuilder: (child) {
        return SliverFillRemaining(child: child);
      },
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
