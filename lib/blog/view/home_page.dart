import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthome/blog/view/settings/settings_page.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/routers/delegate.dart';
import 'package:smarthome/utils/launch_url.dart';
import 'package:smarthome/widgets/home_page.dart';
import 'package:smarthome/widgets/rounded_raised_button.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BlogHomePage extends Page {
  BlogHomePage()
      : super(
          key: const ValueKey('blog'),
          name: '/blog',
        );

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (context) => const BlogHomeScreen(),
    );
  }
}

/// 利用 WebView 实现的博客页面
class BlogHomeScreen extends StatefulWidget {
  const BlogHomeScreen({Key? key}) : super(key: key);

  @override
  _BlogHomeScreenState createState() => _BlogHomeScreenState();
}

class _BlogHomeScreenState extends State<BlogHomeScreen> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppPreferencesBloc, AppPreferencesState>(
      builder: (context, state) => FutureBuilder(
        future: _controller.future,
        builder: (BuildContext context,
                AsyncSnapshot<WebViewController> controller) =>
            MyHomePage(
          activeTab: AppTab.blog,
          actions: [
            Tooltip(
              message: '进入管理页面',
              child: IconButton(
                icon: const Icon(Icons.dvr),
                onPressed: () async {
                  final blogAdminUrl = state.blogAdminUrl;
                  if (blogAdminUrl != null) {
                    if (kIsWeb) {
                      await launchUrl(blogAdminUrl);
                    } else if (controller.hasData) {
                      await controller.data!.loadUrl(blogAdminUrl);
                    }
                  } else {
                    MyRouterDelegate.of(context).push(BlogSettingsPage());
                  }
                },
              ),
            ),
            Tooltip(
              message: '设置',
              child: IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  MyRouterDelegate.of(context).push(BlogSettingsPage());
                },
              ),
            ),
          ],
          body: (!kIsWeb && !Platform.isWindows)
              ? WillPopScope(
                  onWillPop: () async {
                    if (controller.hasData &&
                        await controller.data!.canGoBack()) {
                      await controller.data!.goBack();
                      return false;
                    }
                    return true;
                  },
                  child: WebView(
                    initialUrl: state.blogUrl,
                    javascriptMode: JavascriptMode.unrestricted,
                    onWebViewCreated: _controller.complete,
                  ))
              : Center(
                  child: RoundedRaisedButton(
                    onPressed: () => launchUrl(state.blogUrl),
                    child: const Text('博客'),
                  ),
                ),
          floatingActionButton: controller.hasData
              ? FloatingActionButton(
                  tooltip: '使用浏览器打开',
                  child: const Icon(Icons.open_in_new),
                  onPressed: () async {
                    final currentUrl = await controller.data!.currentUrl();
                    if (currentUrl != null) {
                      await launchUrl(currentUrl);
                    }
                  },
                )
              : null,
        ),
      ),
    );
  }
}

class SettingButton extends StatelessWidget {
  const SettingButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RoundedRaisedButton(
        onPressed: () {
          MyRouterDelegate.of(context).push(BlogSettingsPage());
        },
        child: const Text('设置博客网址'),
      ),
    );
  }
}
