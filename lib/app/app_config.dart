import 'package:flutter/material.dart';

class AppConfig extends InheritedWidget {
  final String appName;
  final String flavorName;
  final String apiUrl;

  // ignore: use_key_in_widget_constructors
  const AppConfig({
    required this.appName,
    required this.flavorName,
    required this.apiUrl,
    required Widget child,
  }) : super(child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;

  static AppConfig of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppConfig>()!;
  }
}
