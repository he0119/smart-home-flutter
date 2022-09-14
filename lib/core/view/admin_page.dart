import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smarthome/app/settings/settings_controller.dart';
import 'package:smarthome/utils/launch_url.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AdminPage extends Page {
  const AdminPage()
      : super(
          key: const ValueKey('admin'),
          name: '/admin',
        );

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (context) => const AdminScreen(),
    );
  }
}

class AdminScreen extends StatefulWidget {
  const AdminScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsController>(
      builder: (context, settings, child) => FutureBuilder(
        future: _controller.future,
        builder: (BuildContext context,
                AsyncSnapshot<WebViewController> controller) =>
            Scaffold(
          body: WillPopScope(
              onWillPop: () async {
                if (controller.hasData && await controller.data!.canGoBack()) {
                  await controller.data!.goBack();
                  return false;
                }
                return true;
              },
              child: SafeArea(
                child: WebView(
                  initialUrl: settings.adminUrl,
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: _controller.complete,
                  initialCookies: [
                    if (settings.cookies != null)
                      ...settings.cookies!.split(';').map(
                        (cookie) {
                          final parts = cookie.split('=');
                          return WebViewCookie(
                              name: parts[0].trim(),
                              value: parts[1].trim(),
                              domain: settings.apiUrl ?? '');
                        },
                      ).toList(),
                  ],
                ),
              )),
          floatingActionButton: controller.hasData
              ? FloatingActionButton(
                  tooltip: '使用浏览器打开',
                  onPressed: () async {
                    final currentUrl = await controller.data!.currentUrl();
                    if (currentUrl != null) {
                      await launchUrl(currentUrl);
                    }
                  },
                  child: const Icon(Icons.open_in_new),
                )
              : null,
        ),
      ),
    );
  }
}
