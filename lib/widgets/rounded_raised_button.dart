import 'package:flutter/material.dart';

class RoundedRaisedButton extends StatelessWidget {
  final Widget? child;
  final Function? onPressed;

  const RoundedRaisedButton({
    super.key,
    this.child,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
      ),
      onPressed: onPressed as void Function()?,
      child: child,
    );
  }
}

class SliverCenterRoundedRaisedButton extends StatelessWidget {
  final Widget? child;
  final Function? onPressed;

  const SliverCenterRoundedRaisedButton({
    super.key,
    this.child,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: RoundedRaisedButton(
          onPressed: onPressed,
          child: child,
        ),
      ),
    );
  }
}
