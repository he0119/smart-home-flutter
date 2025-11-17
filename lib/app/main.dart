import 'dart:io';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/l10n/l10n.dart';
import 'package:smarthome/routers/delegate.dart';
import 'package:smarthome/routers/information_parser.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.delegate});

  final MyRouterDelegate delegate;

  @override
  Widget build(BuildContext context) {
    return MyMaterialApp(delegate: delegate);
  }
}

class MyMaterialApp extends StatefulWidget {
  final MyRouterDelegate delegate;

  const MyMaterialApp({super.key, required this.delegate});

  @override
  State<MyMaterialApp> createState() => _MyMaterialAppState();
}

class _MyMaterialAppState extends State<MyMaterialApp> {
  @override
  void initState() {
    super.initState();
    // 仅在安卓上注册通道
    if (!kIsWeb && Platform.isAndroid) {
      const MethodChannel('hehome.xyz/route').setMethodCallHandler((
        call,
      ) async {
        if (call.method == 'RouteChanged' && call.arguments != null) {
          await widget.delegate.navigateNewPath(call.arguments as String);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp.router(
          scaffoldMessengerKey: scaffoldMessengerKey,
          theme: ThemeData(colorScheme: lightDynamic, useMaterial3: true),
          darkTheme: ThemeData.dark().copyWith(colorScheme: darkDynamic),
          themeMode: ThemeMode.system,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          title: 'SmartHome',
          routeInformationParser: MyRouteInformationParser(),
          routerDelegate: widget.delegate,
        );
      },
    );
  }
}
