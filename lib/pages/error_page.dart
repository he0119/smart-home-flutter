import 'package:flutter/material.dart';

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
          RaisedButton(
            child: Text('重试'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
            ),
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}
