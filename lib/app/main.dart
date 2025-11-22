import 'dart:io';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_selectionarea/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/l10n/l10n.dart';
import 'package:smarthome/utils/launch_url.dart';

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

    if (!kIsWeb && Platform.isAndroid) {
      // 注册通道
      const MethodChannel('hehome.xyz/route').setMethodCallHandler((
        call,
      ) async {
        if (call.method == 'RouteChanged' && call.arguments != null) {
          final uri = Uri.parse(call.arguments as String);
          _router.go(uri.path);
        }
      });
      // 检查更新
      ref.read(updateProvider.notifier).checkUpdate();
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
          restorationScopeId: 'app',
          scaffoldMessengerKey: scaffoldMessengerKey,
          theme: ThemeData(colorScheme: lightDynamic, useMaterial3: true),
          darkTheme: ThemeData.dark().copyWith(colorScheme: darkDynamic),
          themeMode: themeMode,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          title: title,
          routerConfig: _router,
          builder: (context, child) {
            return UpdateListener(child: child!);
          },
        );
      },
    );
  }
}

class UpdateListener extends ConsumerWidget {
  final Widget child;

  const UpdateListener({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(updateProvider, (_, state) {
      if (state.needUpdate) {
        final router = ref.read(routerProvider);
        final navigator = router.routerDelegate.navigatorKey.currentState;
        if (navigator != null) {
          navigator.push(
            DialogRoute(
              context: navigator.context,
              builder: (_) => AlertDialog(
                title: const Text('更新'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('发现新版本：${state.version}'),
                    if (state.changelog != null) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 200,
                        width: double.maxFinite,
                        child: SingleChildScrollView(
                          child: MarkdownBody(data: state.changelog!),
                        ),
                      ),
                    ],
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      router.pop();
                    },
                    child: const Text('稍后'),
                  ),
                  TextButton(
                    onPressed: () async {
                      router.pop();
                      if (state.url != null) {
                        launchUrl(state.url!);
                      }
                    },
                    child: const Text('下载'),
                  ),
                ],
              ),
            ),
          );
        }
      }
    });
    return child;
  }
}
