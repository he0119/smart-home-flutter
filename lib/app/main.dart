import 'dart:io';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/core/router/router.dart';
import 'package:smarthome/l10n/l10n.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = ref.read(routerProvider);

    // 仅在安卓上注册通道
    if (!kIsWeb && Platform.isAndroid) {
      const MethodChannel('hehome.xyz/route').setMethodCallHandler((
        call,
      ) async {
        if (call.method == 'RouteChanged' && call.arguments != null) {
          final uri = Uri.parse(call.arguments as String);
          _router.go(uri.path);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(
      settingsProvider.select((settings) => settings.themeMode),
    );
    final title = ref.read(
      settingsProvider.select((settings) => settings.appConfig.appName),
    );

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp.router(
          scaffoldMessengerKey: scaffoldMessengerKey,
          theme: ThemeData(colorScheme: lightDynamic, useMaterial3: true),
          darkTheme: ThemeData.dark().copyWith(colorScheme: darkDynamic),
          themeMode: themeMode,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          title: title,
          routerConfig: _router,
        );
      },
    );
  }
}
