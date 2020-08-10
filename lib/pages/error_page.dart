import 'package:flutter/material.dart';
import 'package:smart_home/widgets/rounded_raised_button.dart';

class ErrorPage extends StatelessWidget {
  final Function onPressed;
  final String message;

  const ErrorPage({
    Key key,
    @required this.onPressed,
    @required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message),
          RoundedRaisedButton(
            child: Text('重试'),
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}
