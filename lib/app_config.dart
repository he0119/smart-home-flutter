import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class AppConfig extends InheritedWidget {
  final String appName;
  final String flavorName;
  final String apiUrl;

  AppConfig({
    @required this.appName,
    @required this.flavorName,
    @required this.apiUrl,
    @required Widget child,
  }) : super(child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;

  static AppConfig of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppConfig>();
  }
}
