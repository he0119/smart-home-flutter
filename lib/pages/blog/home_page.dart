import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/models/app_tab.dart';
import 'package:smart_home/models/grobal_keys.dart';
import 'package:smart_home/utils/launch_url.dart';
import 'package:smart_home/widgets/tab_selector.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BlogHomePage extends StatelessWidget {
  const BlogHomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('博客'),
      ),
      body: _BlogHomeBody(),
      bottomNavigationBar: TabSelector(
        activeTab: AppTab.blog,
        onTabSelected: (tab) =>
            BlocProvider.of<TabBloc>(context).add(UpdateTab(tab)),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.open_in_new),
        onPressed: () async {
          const url = 'https://hehome.xyz';
          await launchUrl(url);
        },
      ),
    );
  }
}

class _BlogHomeBody extends StatelessWidget {
  const _BlogHomeBody({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const String url = 'https://hehome.xyz';
    return !kIsWeb
        ? WebView(
            key: UniqueKey(),
            initialUrl: url,
            javascriptMode: JavascriptMode.unrestricted,
          )
        : Center(
            child: RaisedButton(
              onPressed: () => launchUrl(url),
              child: Text('博客'),
            ),
          );
  }
}
