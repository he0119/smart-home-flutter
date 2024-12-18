import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smarthome/app/settings/settings_controller.dart';
import 'package:smarthome/blog/view/settings/settings_page.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/routers/delegate.dart';
import 'package:smarthome/utils/launch_url.dart';
import 'package:smarthome/widgets/home_page.dart';
import 'package:smarthome/widgets/rounded_raised_button.dart';
import 'package:smarthome/widgets/webview.dart';

class BlogHomePage extends Page {
  const BlogHomePage()
      : super(
          key: const ValueKey('blog'),
          name: '/blog',
        );

  @override
  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
      settings: this,
      pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) =>
          FadeTransition(
        opacity: animation,
        child: const BlogHomeScreen(),
      ),
    );
  }
}

/// 利用 WebView 实现的博客页面
class BlogHomeScreen extends StatefulWidget {
  const BlogHomeScreen({super.key});

  @override
  State<BlogHomeScreen> createState() => _BlogHomeScreenState();
}

class _BlogHomeScreenState extends State<BlogHomeScreen> {
  late NestedWebviewController _controller;

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsController>(
      builder: (context, settings, child) {
        if (!kIsWeb && !Platform.isWindows) {
          _controller = NestedWebviewController(settings.blogUrl);
        }
        return MyHomePage(
          activeTab: AppTab.blog,
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
                      await _controller.webviewController
                          .loadRequest(Uri.parse(blogAdminUrl));
                    }
                  } else {
                    MyRouterDelegate.of(context).push(const BlogSettingsPage());
                  }
                },
              ),
            ),
            Tooltip(
              message: '设置',
              child: IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  MyRouterDelegate.of(context).push(const BlogSettingsPage());
                },
              ),
            ),
          ],
          slivers: [
            (!kIsWeb && !Platform.isWindows)
                ? SliverWebview(
                    controller: _controller,
                  )
                : SliverCenterRoundedRaisedButton(
                    onPressed: () => launchUrl(settings.blogUrl),
                    child: const Text('博客'),
                  )
          ],
          floatingActionButton: FloatingActionButton(
            tooltip: '使用浏览器打开',
            onPressed: () async {
              final currentUrl =
                  await _controller.webviewController.currentUrl();
              if (currentUrl != null) {
                await launchUrl(currentUrl);
              }
            },
            child: const Icon(Icons.open_in_new),
          ),
          // FIXME: 目前没法通过返回键退出应用
          canPop: () => false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) {
              return;
            }

            final NavigatorState navigator = Navigator.of(context);
            final canGoBack = await _controller.webviewController.canGoBack();
            if (canGoBack) {
              await _controller.webviewController.goBack();
            } else {
              navigator.pop();
            }
          },
        );
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
          MyRouterDelegate.of(context).push(const BlogSettingsPage());
        },
        child: const Text('设置博客网址'),
      ),
    );
  }
}
