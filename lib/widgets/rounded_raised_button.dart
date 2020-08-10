import 'package:flutter/material.dart';

class RoundedRaisedButton extends StatelessWidget {
  final Widget child;
  final Function onPressed;

  const RoundedRaisedButton({
    Key key,
    this.child,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.0),
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}
