import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/utils/launch_url.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AdminPage extends Page {
  const AdminPage() : super(key: const ValueKey('admin'), name: '/admin');

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (context) => const AdminScreen(),
    );
  }
}

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  final WebViewController controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted);

  final WebViewCookieManager webViewCookieManager = WebViewCookieManager();

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    if (settings.cookies != null) {
      final cookies = settings.cookies!.split(';');
      for (final cookie in cookies) {
        final parts = cookie.split('=');
        final name = parts[0].trim();
        final value = parts[1].trim();
        final domain = settings.adminUrl
            .replaceFirst('https://', '')
            .replaceFirst('http://', '');
        webViewCookieManager.setCookie(
          WebViewCookie(name: name, value: value, domain: domain),
        );
      }
    }
    controller.loadRequest(Uri.parse(settings.adminUrl));
    return Scaffold(
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) async {
          if (didPop) {
            return;
          }
          final NavigatorState navigator = Navigator.of(context);
          final bool canGoBack = await controller.canGoBack();
          if (canGoBack) {
            controller.goBack();
          } else {
            navigator.pop();
          }
        },
        child: SafeArea(child: WebViewWidget(controller: controller)),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: '使用浏览器打开',
        onPressed: () async {
          final currentUrl = await controller.currentUrl();
          if (currentUrl != null) {
            await launchUrl(currentUrl);
          }
        },
        child: const Icon(Icons.open_in_new),
      ),
    );
  }
}
