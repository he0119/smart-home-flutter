import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/models/app_tab.dart';
import 'package:smart_home/pages/settings/blog/settings._page.dart';
import 'package:smart_home/utils/launch_url.dart';
import 'package:smart_home/widgets/home_page.dart';
import 'package:smart_home/widgets/rounded_raised_button.dart';
import 'package:webview_flutter/webview_flutter.dart';

enum BlogMenu { admin, setting }

/// 利用 WebView 实现的博客页面
class BlogHomePage extends StatefulWidget {
  const BlogHomePage({Key key}) : super(key: key);

  @override
  _BlogHomePageState createState() => _BlogHomePageState();
}

class _BlogHomePageState extends State<BlogHomePage> {
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
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => BlogSettingsPage(),
                    ));
                  }
                },
              ),
            ),
            Tooltip(
              message: '设置',
              child: IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => BlogSettingsPage()),
                  );
                },
              ),
            ),
          ],
          body: !kIsWeb
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
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => BlogSettingsPage(),
          ));
        },
        child: Text('设置博客网址'),
      ),
    );
  }
}
