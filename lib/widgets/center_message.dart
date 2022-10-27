import 'package:flutter/material.dart';

class CenterMessage extends StatelessWidget {
  final String message;

  const CenterMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(message));
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
