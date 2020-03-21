import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/pages/storage/home_page.dart';
import 'package:smart_home/pages/storage/search_page.dart';
import 'package:smart_home/pages/storage/storage_datail_page.dart';
import 'package:smart_home/widgets/show_snack_bar.dart';
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
          appBar: _buildAppBar(context, activeTab),
          body: MultiBlocListener(
            listeners: [
              BlocListener<SnackBarBloc, SnackBarState>(
                condition: (previous, current) {
                  if (current is SnackBarSuccess &&
                      current.position == SnackBarPosition.home) {
                    return true;
                  }
                  return false;
                },
                listener: (context, state) {
                  if (state is SnackBarSuccess &&
                      state.type == MessageType.error) {
                    showErrorSnackBar(context, state.message);
                  }
                  if (state is SnackBarSuccess &&
                      state.type == MessageType.info) {
                    showInfoSnackBar(context, state.message);
                  }
                },
              ),
              BlocListener<UpdateBloc, UpdateState>(
                listener: (context, state) {
                  if (state is UpdateSuccess)
                    showInfoSnackBar(context, state.needUpdate.toString());
                },
              ),
            ],
            child: _buildBody(context, activeTab),
          ),
          bottomNavigationBar: TabSelector(
            activeTab: activeTab,
            onTabSelected: (tab) =>
                BlocProvider.of<TabBloc>(context).add(UpdateTab(tab)),
          ),
          floatingActionButton: _buildFloatingActionButton(context, activeTab),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context, AppTab activeTab) {
    if (activeTab == AppTab.storage) {
      return AppBar(
        title: Text('物品管理'),
        actions: <Widget>[
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
    if (activeTab == AppTab.board) {
      return AppBar(
        title: Text('留言板'),
      );
    }
    return null;
  }

  Widget _buildBody(BuildContext context, AppTab activeTab) {
    if (activeTab == AppTab.storage) {
      return StorageHomePage();
    }
    if (activeTab == AppTab.iot) {
      return WebView(
        key: UniqueKey(),
        initialUrl: 'https://iot.hehome.xyz',
        javascriptMode: JavascriptMode.unrestricted,
      );
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
  }

  FloatingActionButton _buildFloatingActionButton(
      BuildContext context, AppTab activeTab) {
    if (activeTab == AppTab.blog) {
      return FloatingActionButton(
        child: Icon(Icons.open_in_new),
        onPressed: () async {
          const url = 'https://hehome.xyz';
          if (await canLaunch(url)) {
            await launch(url);
          } else {
            throw 'Could not launch $url';
          }
        },
      );
    }
    if (activeTab == AppTab.storage) {
      return FloatingActionButton(
        child: Icon(Icons.storage),
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StorageDetailPage(),
            ),
          );
        },
      );
    }
    return null;
  }
}
