import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/core/blocs.dart';
import 'package:smart_home/models/app_tab.dart';
import 'package:smart_home/pages/settings/blog/settings_page.dart';
import 'package:smart_home/routers/delegate.dart';
import 'package:smart_home/utils/launch_url.dart';
import 'package:smart_home/widgets/home_page.dart';
import 'package:smart_home/widgets/rounded_raised_button.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BlogHomePage extends Page {
  BlogHomePage()
      : super(
          key: ValueKey('blog'),
          name: '/blog',
        );

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (context) => BlogHomeScreen(),
    );
  }
}

/// 利用 WebView 实现的博客页面
class BlogHomeScreen extends StatefulWidget {
  const BlogHomeScreen({Key key}) : super(key: key);

  @override
  _BlogHomeScreenState createState() => _BlogHomeScreenState();
}

class _BlogHomeScreenState extends State<BlogHomeScreen> {
  Completer<WebViewController> _controller = Completer<WebViewController>();

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
                icon: Icon(Icons.dvr),
                onPressed: () async {
                  if (state.blogAdminUrl != null) {
                    if (kIsWeb) {
                      await launchUrl(state.blogAdminUrl);
                    } else if (controller.hasData) {
                      controller.data.loadUrl(state.blogAdminUrl);
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
                icon: Icon(Icons.settings),
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
                        await controller.data.canGoBack()) {
                      controller.data.goBack();
                      return false;
                    }
                    return true;
                  },
                  child: state.blogUrl != null
                      ? WebView(
                          initialUrl: state.blogUrl,
                          javascriptMode: JavascriptMode.unrestricted,
                          onWebViewCreated: (controller) {
                            _controller.complete((controller));
                          },
                        )
                      : SettingButton(),
                )
              : state.blogUrl != null
                  ? Center(
                      child: RoundedRaisedButton(
                        onPressed: () => launchUrl(state.blogUrl),
                        child: Text('博客'),
                      ),
                    )
                  : SettingButton(),
          floatingActionButton: controller.hasData
              ? FloatingActionButton(
                  tooltip: '使用浏览器打开',
                  child: Icon(Icons.open_in_new),
                  onPressed: () async {
                    await launchUrl(await controller.data.currentUrl());
                  },
                )
              : null,
        ),
      ),
    );
  }
}

class SettingButton extends StatelessWidget {
  const SettingButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RoundedRaisedButton(
        onPressed: () {
          MyRouterDelegate.of(context).push(BlogSettingsPage());
        },
        child: Text('设置博客网址'),
      ),
    );
  }
}
