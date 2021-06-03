import 'package:flutter/material.dart';
import 'package:smarthome/widgets/rounded_raised_button.dart';

/// 居中的可以显示错误提示的按钮
class ErrorMessageButton extends StatelessWidget {
  final Function onPressed;
  final String message;

  const ErrorMessageButton({
    Key? key,
    required this.onPressed,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message),
          RoundedRaisedButton(
            onPressed: onPressed,
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }
}
