import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/pages/storage/home_page.dart';
import 'package:smart_home/pages/storage/search_page.dart';
import 'package:smart_home/pages/storage/storage_add_edit_page.dart';
import 'package:smart_home/widgets/tab_selector.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 仅在客户端上注册 Shortcut
    if (!kIsWeb) {
      final QuickActions quickActions = QuickActions();
      quickActions.initialize((String shortcutType) async {
        if (shortcutType == 'action_iot') {
          BlocProvider.of<TabBloc>(context).add(UpdateTab(AppTab.iot));
        } else {
          BlocProvider.of<TabBloc>(context).add(UpdateTab(AppTab.blog));
        }
      });
      quickActions.setShortcutItems(
        <ShortcutItem>[
          // TODO: 给快捷方式添加图标
          const ShortcutItem(type: 'action_iot', localizedTitle: 'IOT'),
          const ShortcutItem(type: 'action_blog', localizedTitle: '博客'),
        ],
      );
    }

    return BlocBuilder<TabBloc, AppTab>(
      builder: (context, activeTab) {
        return Scaffold(
          appBar: activeTab == AppTab.iot ? null : _AppBar(),
          body: _HomePageBody(),
          bottomNavigationBar: TabSelector(
            activeTab: activeTab,
            onTabSelected: (tab) =>
                BlocProvider.of<TabBloc>(context).add(UpdateTab(tab)),
          ),
          floatingActionButton: activeTab == AppTab.blog
              ? FloatingActionButton(
                  child: Icon(Icons.open_in_new),
                  onPressed: () async {
                    const url = 'https://hehome.xyz';
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                  })
              : null,
        );
      },
    );
  }
}

class _AppBar extends StatelessWidget with PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TabBloc, AppTab>(
      builder: (context, activeTab) {
        if (activeTab == AppTab.storage) {
          return AppBar(
            title: Text('物品管理'),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StorageAddEditStoagePage(
                        isEditing: false,
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SearchPage()),
                  );
                },
              ),
            ],
          );
        }
        if (activeTab == AppTab.blog) {
          return AppBar(
            title: Text('博客'),
          );
        }
        return AppBar(title: Text('留言板'));
      },
    );
  }
}

class _HomePageBody extends StatelessWidget {
  const _HomePageBody({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TabBloc, AppTab>(
      builder: (context, activeTab) {
        if (activeTab == AppTab.iot) {
          return WebView(
            key: UniqueKey(),
            initialUrl: 'https://iot.hehome.xyz',
            javascriptMode: JavascriptMode.unrestricted,
          );
        }
        if (activeTab == AppTab.storage) {
          return StorageHomePage();
        }
        if (activeTab == AppTab.blog) {
          return WebView(
            key: UniqueKey(),
            initialUrl: 'https://hehome.xyz',
            javascriptMode: JavascriptMode.unrestricted,
          );
        }
        return Center(
          child: Text(
            'Index 2: 留言板',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }
}
