import 'package:flutter/material.dart';

class CenterLoadingIndicator extends StatelessWidget {
  const CenterLoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}
