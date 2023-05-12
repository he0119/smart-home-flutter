import 'dart:io';

import 'package:extended_sliver/extended_sliver.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MyWebview extends StatelessWidget {
  const MyWebview({super.key, required this.controller});

  final NestedWebviewController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: controller.scrollHeightNotifier,
      builder: (
        BuildContext context,
        double scrollHeight,
        Widget? child,
      ) {
        return SliverToNestedScrollBoxAdapter(
          childExtent: scrollHeight,
          onScrollOffsetChanged: (double scrollOffset) {
            double y = scrollOffset;
            if (Platform.isAndroid) {
              // https://github.com/flutter/flutter/issues/75841
              y *= View.of(context).devicePixelRatio;
            }
            controller.webviewController?.scrollTo(0, y.ceil());
          },
          child: child,
        );
      },
      child: WebView(
        initialUrl: controller.initialUrl,
        onPageStarted: controller.onPageStarted,
        onPageFinished: controller.onPageFinished,
        onWebResourceError: controller.onWebResourceError,
        onWebViewCreated: controller.onWebViewCreated,
        onProgress: controller.onProgress,
        javascriptChannels: <JavascriptChannel>{
          controller.scrollHeightNotifierJavascriptChannel
        },
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}

class NestedWebviewController {
  NestedWebviewController(this.initialUrl);

  final String initialUrl;

  WebViewController? _webviewController;

  WebViewController? get webviewController => _webviewController;

  ValueNotifier<double> scrollHeightNotifier = ValueNotifier<double>(1);
  ValueNotifier<WebViewStatus> webViewStatusNotifier =
      ValueNotifier<WebViewStatus>(WebViewStatus.loading);

  ValueNotifier<int> progressNotifier = ValueNotifier<int>(0);

  void onWebViewCreated(WebViewController controller) {
    _webviewController = controller;
  }

  void onPageStarted(String url) {
    if (url == initialUrl ||
        webViewStatusNotifier.value == WebViewStatus.failed) {
      webViewStatusNotifier.value = WebViewStatus.loading;
    }
  }

  void onPageFinished(String url) {
    if (webViewStatusNotifier.value != WebViewStatus.failed) {
      //webViewStatusNotifier.value = WebViewStatus.completed;
      _webviewController?.runJavascript(scrollHeightJs);
    }
  }

  void onWebResourceError(WebResourceError error) {
    webViewStatusNotifier.value = WebViewStatus.failed;
  }

  void onProgress(int progress) {
    progressNotifier.value = progress;
  }

  JavascriptChannel get scrollHeightNotifierJavascriptChannel =>
      JavascriptChannel(
        name: 'ScrollHeightNotifier',
        onMessageReceived: (JavascriptMessage message) {
          final String msg = message.message;
          final double? height = double.tryParse(msg);
          if (height != null) {
            scrollHeightNotifier.value = height;

            webViewStatusNotifier.value = WebViewStatus.completed;
          }
        },
      );
}

enum WebViewStatus {
  loading,
  failed,
  completed,
}

const String scrollHeightJs = '''(function() {
  var height = 0;
  var notifier = window.ScrollHeightNotifier || window.webkit.messageHandlers.ScrollHeightNotifier;
  if (!notifier) return;
  function checkAndNotify() {
    var curr = document.body.scrollHeight;
    if (curr !== height) {
      height = curr;
      notifier.postMessage(height.toString());
    }
  }
  var timer;
  var ob;
  if (window.ResizeObserver) {
    ob = new ResizeObserver(checkAndNotify);
    ob.observe(document.body);
  } else {
    timer = setTimeout(checkAndNotify, 200);
  }
  window.onbeforeunload = function() {
    ob && ob.disconnect();
    timer && clearTimeout(timer);
  };
})();''';
