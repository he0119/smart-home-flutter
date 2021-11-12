import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthome/core/bloc/app_preferences/app_preferences_bloc.dart';
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
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppPreferencesBloc, AppPreferencesState>(
      builder: (context, state) => FutureBuilder(
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
              child: WebView(
                initialUrl: state.blogUrl,
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: _controller.complete,
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
