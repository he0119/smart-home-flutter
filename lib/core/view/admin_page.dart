import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/utils/launch_url.dart';
import 'package:smarthome/widgets/state_views.dart';
import 'package:smarthome/widgets/webview.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminScreen();
  }
}

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  final WebViewController _controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted);
  final WebViewCookieManager _cookieManager = WebViewCookieManager();
  final ValueNotifier<WebViewStatus> _status = ValueNotifier<WebViewStatus>(
    WebViewStatus.loading,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _status.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final settings = ref.read(settingsProvider);
    await _setCookies(settings.cookies, settings.adminUrl);
    _controller.setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (_) => _status.value = WebViewStatus.completed,
        onWebResourceError: (_) => _status.value = WebViewStatus.failed,
      ),
    );
    await _controller.loadRequest(Uri.parse(settings.adminUrl));
  }

  /// cookie 片段可能没有等号、值里也可能再出现等号，按第一个等号切
  Future<void> _setCookies(String? cookies, String adminUrl) async {
    final host = Uri.tryParse(adminUrl)?.host;
    if (cookies == null || host == null || host.isEmpty) {
      return;
    }
    for (final segment in cookies.split(';')) {
      final index = segment.indexOf('=');
      if (index <= 0) {
        continue;
      }
      final name = segment.substring(0, index).trim();
      final value = segment.substring(index + 1).trim();
      if (name.isEmpty) {
        continue;
      }
      await _cookieManager.setCookie(
        WebViewCookie(name: name, value: value, domain: host),
      );
    }
  }

  void _retry() {
    _status.value = WebViewStatus.loading;
    _controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('管理'),
        actions: <Widget>[
          IconButton(
            tooltip: '刷新',
            icon: const Icon(Icons.refresh),
            onPressed: _retry,
          ),
        ],
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) async {
          if (didPop) {
            return;
          }
          final navigator = Navigator.of(context);
          final canGoBack = await _controller.canGoBack();
          if (canGoBack) {
            await _controller.goBack();
          } else {
            navigator.pop();
          }
        },
        child: ValueListenableBuilder<WebViewStatus>(
          valueListenable: _status,
          builder: (context, status, child) {
            return switch (status) {
              WebViewStatus.loading => const LoadingState(message: '正在打开管理页面'),
              WebViewStatus.failed => ErrorState(
                message: '管理页面打不开，检查管理网址后重试',
                onRetry: _retry,
              ),
              WebViewStatus.completed => child!,
            };
          },
          child: WebViewWidget(controller: _controller),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: '使用浏览器打开',
        onPressed: () async {
          final currentUrl = await _controller.currentUrl();
          if (currentUrl != null) {
            await launchUrl(currentUrl);
          }
        },
        child: const Icon(Icons.open_in_new),
      ),
    );
  }
}
