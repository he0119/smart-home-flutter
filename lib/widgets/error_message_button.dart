import 'package:material_ui/material_ui.dart';
import 'package:smarthome/widgets/state_views.dart';

/// 居中的可以显示错误提示的按钮
class ErrorMessageButton extends StatelessWidget {
  final Function onPressed;
  final String message;

  const ErrorMessageButton({
    super.key,
    required this.onPressed,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorState(message: message, onRetry: () => onPressed());
  }
}

class SliverErrorMessageButton extends StatelessWidget {
  final Function onPressed;
  final String message;

  const SliverErrorMessageButton({
    super.key,
    required this.onPressed,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: ErrorMessageButton(message: message, onPressed: onPressed),
    );
  }
}
