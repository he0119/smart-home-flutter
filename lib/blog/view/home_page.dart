import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/core/router/router_extensions.dart';
import 'package:smarthome/utils/launch_url.dart';
import 'package:smarthome/widgets/center_loading_indicator.dart';
import 'package:smarthome/widgets/home_page.dart';
import 'package:smarthome/widgets/state_views.dart';
import 'package:smarthome/widgets/webview.dart';

class BlogHomePage extends StatelessWidget {
  const BlogHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const BlogHomeScreen();
  }
}

/// 利用 WebView 实现的博客页面
class BlogHomeScreen extends ConsumerStatefulWidget {
  const BlogHomeScreen({super.key});

  @override
  ConsumerState<BlogHomeScreen> createState() => _BlogHomeScreenState();
}

class _BlogHomeScreenState extends ConsumerState<BlogHomeScreen> {
  NestedWebviewController? _controller;

  bool get _useWebview => !kIsWeb && !Platform.isWindows;

  @override
  void initState() {
    super.initState();
    if (_useWebview) {
      _controller = NestedWebviewController(ref.read(settingsProvider).blogUrl)
        ..initialize();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    // 网址改了才重新加载，不要每次重建都新起一个控制器
    ref.listen(settingsProvider.select((s) => s.blogUrl), (previous, next) {
      if (previous != next && next.isNotEmpty) {
        _controller?.webviewController.loadRequest(Uri.parse(next));
      }
    });

    return MyHomePage(
      title: AppTab.blog.name,
      actions: <Widget>[
        IconButton(
          tooltip: '进入管理页面',
          icon: const Icon(Icons.dvr),
          onPressed: () async {
            final blogAdminUrl = settings.blogAdminUrl;
            if (blogAdminUrl != null) {
              if (kIsWeb) {
                await launchUrl(blogAdminUrl);
              } else {
                await _controller?.webviewController.loadRequest(
                  Uri.parse(blogAdminUrl),
                );
              }
            } else {
              context.goBlogSettings();
            }
          },
        ),
        IconButton(
          tooltip: '博客设置',
          icon: const Icon(Icons.settings),
          onPressed: () {
            context.goBlogSettings();
          },
        ),
      ],
      slivers: <Widget>[
        if (!_useWebview)
          SliverEmptyState(
            icon: Icons.rss_feed,
            title: '博客在浏览器里打开',
            message: settings.blogUrl,
            action: FilledButton.tonal(
              onPressed: () => launchUrl(settings.blogUrl),
              child: const Text('打开博客'),
            ),
          )
        else
          _buildWebview(),
      ],
      floatingActionButton: _useWebview
          ? FloatingActionButton(
              tooltip: '使用浏览器打开',
              onPressed: () async {
                final currentUrl = await _controller?.webviewController
                    .currentUrl();
                if (currentUrl != null) {
                  await launchUrl(currentUrl);
                }
              },
              child: const Icon(Icons.open_in_new),
            )
          : null,
      canPop: () => !_useWebview,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || !_useWebview) {
          return;
        }
        final controller = _controller;
        if (controller == null) {
          return;
        }
        final canGoBack = await controller.webviewController.canGoBack();
        if (canGoBack) {
          await controller.webviewController.goBack();
        } else {
          SystemNavigator.pop();
        }
      },
    );
  }

  Widget _buildWebview() {
    final controller = _controller!;
    return ValueListenableBuilder<WebViewStatus>(
      valueListenable: controller.webViewStatusNotifier,
      builder: (context, status, child) {
        return switch (status) {
          WebViewStatus.loading => const SliverCenterLoadingIndicator(),
          WebViewStatus.failed => SliverErrorState(
            message: '博客页面打不开，检查网址或网络后重试',
            onRetry: () => controller.webviewController.reload(),
          ),
          WebViewStatus.completed => child!,
        };
      },
      child: SliverWebview(controller: controller),
    );
  }
}
