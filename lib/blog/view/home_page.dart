import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/core/router/router_extensions.dart';
import 'package:smarthome/utils/launch_url.dart';
import 'package:smarthome/widgets/home_page.dart';
import 'package:smarthome/widgets/rounded_raised_button.dart';
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
  late NestedWebviewController _controller;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    if (!kIsWeb && !Platform.isWindows) {
      _controller = NestedWebviewController(settings.blogUrl);
    }
    return MyHomePage(
      title: AppTab.blog.name,
      actions: [
        Tooltip(
          message: '进入管理页面',
          child: IconButton(
            icon: const Icon(Icons.dvr),
            onPressed: () async {
              final blogAdminUrl = settings.blogAdminUrl;
              if (blogAdminUrl != null) {
                if (kIsWeb) {
                  await launchUrl(blogAdminUrl);
                } else {
                  await _controller.webviewController.loadRequest(
                    Uri.parse(blogAdminUrl),
                  );
                }
              } else {
                context.goBlogSettings();
              }
            },
          ),
        ),
        Tooltip(
          message: '设置',
          child: IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.goBlogSettings();
            },
          ),
        ),
      ],
      slivers: [
        (!kIsWeb && !Platform.isWindows)
            ? SliverWebview(controller: _controller)
            : SliverCenterRoundedRaisedButton(
                onPressed: () => launchUrl(settings.blogUrl),
                child: const Text('博客'),
              ),
      ],
      floatingActionButton: FloatingActionButton(
        tooltip: '使用浏览器打开',
        onPressed: () async {
          final currentUrl = await _controller.webviewController.currentUrl();
          if (currentUrl != null) {
            await launchUrl(currentUrl);
          }
        },
        child: const Icon(Icons.open_in_new),
      ),
      canPop: () => false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }

        final canGoBack = await _controller.webviewController.canGoBack();
        if (canGoBack) {
          await _controller.webviewController.goBack();
        } else {
          // 退出应用
          SystemNavigator.pop();
        }
      },
    );
  }
}

class SettingButton extends StatelessWidget {
  const SettingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RoundedRaisedButton(
        onPressed: () {
          context.goBlogSettings();
        },
        child: const Text('设置博客网址'),
      ),
    );
  }
}
