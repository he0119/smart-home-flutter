import 'package:flutter/material.dart';

class SplashPage extends Page {
  SplashPage()
      : super(
          key: const ValueKey('splash'),
          name: '/splash',
        );

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (context) => SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  SplashScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
