import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/models/app_tab.dart';
import 'package:smart_home/models/grobal_keys.dart';
import 'package:smart_home/pages/blog/setting_page.dart';
import 'package:smart_home/utils/launch_url.dart';
import 'package:smart_home/widgets/tab_selector.dart';
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
      builder: (context, state) => Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: Text('博客'),
          actions: [
            FutureBuilder(
              future: _controller.future,
              builder: (BuildContext context,
                  AsyncSnapshot<WebViewController> controller) {
                if (controller.hasData) {
                  return PopupMenuButton(
                    onSelected: (value) {
                      if (value == BlogMenu.admin &&
                          state.blogAdminUrl != null) {
                        controller.data.loadUrl(state.blogAdminUrl);
                      } else {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => BlogSettingPage(
                            blogUrl: state.blogUrl,
                            blogAdminUrl: state.blogAdminUrl,
                          ),
                        ));
                      }
                    },
                    itemBuilder: (context) => <PopupMenuItem<BlogMenu>>[
                      PopupMenuItem(
                        value: BlogMenu.admin,
                        child: Text('进入后台'),
                      ),
                      PopupMenuItem(
                        value: BlogMenu.setting,
                        child: Text('设置网址'),
                      ),
                    ],
                  );
                }
                return Container();
              },
            )
          ],
        ),
        body: !kIsWeb
            ? WebView(
                initialUrl: state.blogUrl,
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (controller) {
                  _controller.complete((controller));
                },
              )
            : Center(
                child: RaisedButton(
                  onPressed: () => launchUrl(state.blogUrl),
                  child: Text('博客'),
                ),
              ),
        bottomNavigationBar: TabSelector(
          activeTab: AppTab.blog,
          onTabSelected: (tab) =>
              BlocProvider.of<TabBloc>(context).add(TabChanged(tab)),
        ),
        floatingActionButton: state.blogUrl != null
            ? FloatingActionButton(
                child: Icon(Icons.open_in_new),
                onPressed: () async {
                  await launchUrl(state.blogUrl);
                },
              )
            : null,
      ),
    );
  }
}
