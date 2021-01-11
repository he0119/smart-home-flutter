import 'dart:io';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:smart_home/blocs/board/blocs.dart';
import 'package:smart_home/blocs/core/blocs.dart';
import 'package:smart_home/blocs/storage/blocs.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/pages/blog/home_page.dart';
import 'package:smart_home/pages/board/home_page.dart';
import 'package:smart_home/pages/iot/home_page.dart';
import 'package:smart_home/pages/storage/home_page.dart';

class HomePage extends Page {
  final AppTab appTab;

  HomePage({
    @required this.appTab,
  }) : super(
          key: ValueKey(appTab.toString()),
          name: '/${EnumToString.convertToString(appTab)}',
        );

  @override
  Route createRoute(BuildContext context) {
    // 仅在客户端上注册 Shortcut
    if (!kIsWeb && !Platform.isWindows) {
      final QuickActions quickActions = QuickActions();
      quickActions.initialize((String shortcutType) async {
        if (shortcutType == 'action_iot') {
          BlocProvider.of<TabBloc>(context).add(TabChanged(AppTab.iot));
        } else if (shortcutType == 'action_storage') {
          BlocProvider.of<TabBloc>(context).add(TabChanged(AppTab.storage));
        } else if (shortcutType == 'action_blog') {
          BlocProvider.of<TabBloc>(context).add(TabChanged(AppTab.blog));
        } else {
          BlocProvider.of<TabBloc>(context).add(TabChanged(AppTab.board));
        }
      });
      quickActions.setShortcutItems(
        <ShortcutItem>[
          // TODO: 给快捷方式添加图标
          const ShortcutItem(type: 'action_iot', localizedTitle: 'IOT'),
          const ShortcutItem(type: 'action_storage', localizedTitle: '物品'),
          const ShortcutItem(type: 'action_blog', localizedTitle: '博客'),
          const ShortcutItem(type: 'action_board', localizedTitle: '留言'),
        ],
      );
    }
    return MaterialPageRoute(
      settings: this,
      builder: (context) => HomeScreen(
        appTab: appTab,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final AppTab appTab;

  const HomeScreen({
    Key key,
    @required this.appTab,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (appTab == AppTab.storage) {
      BlocProvider.of<StorageHomeBloc>(context)
          .add(StorageHomeFetched(itemType: ItemType.all));
      return StorageHomePage();
    }
    if (appTab == AppTab.blog) {
      return BlogHomePage();
    }
    if (appTab == AppTab.iot) {
      return IotHomePage();
    }
    BlocProvider.of<BoardHomeBloc>(context).add(BoardHomeFetched());
    return BoardHomePage();
  }
}
