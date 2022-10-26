import 'package:flutter/widgets.dart';

/// https://gist.github.com/ltOgt/3771c824fc1c8811f5ec1a81a9a4937b
/// Conditionally wrap a subtree with a parent widget without breaking the code tree.
///
/// [condition]: the condition depending on which the subtree [child] is wrapped with the parent.
/// [child]: The subtree that should always be build.
/// [conditionalBuilder]: builds the parent with the subtree [child].
///
/// ___________
/// Usage:
/// ```dart
/// return ConditionalParentWidget(
///   condition: shouldIncludeParent,
///   child: Widget1(
///     child: Widget2(
///       child: Widget3(),
///     ),
///   ),
///   conditionalBuilder: (Widget child) => SomeParentWidget(child: child),
///);
/// ```
///
/// ___________
/// Instead of:
/// ```dart
/// Widget child = Widget1(
///   child: Widget2(
///     child: Widget3(),
///   ),
/// );
///
/// return shouldIncludeParent ? SomeParentWidget(child: child) : child;
/// ```
///
class ConditionalParentWidget extends StatelessWidget {
  const ConditionalParentWidget({
    super.key,
    required this.condition,
    required this.child,
    required this.conditionalBuilder,
  });

  final Widget child;
  final bool condition;
  final Widget Function(Widget child) conditionalBuilder;

  @override
  Widget build(BuildContext context) {
    return condition ? conditionalBuilder(child) : child;
  }
}
