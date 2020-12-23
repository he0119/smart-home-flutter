import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quick_actions/quick_actions.dart';

import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/blocs/board/blocs.dart';
import 'package:smart_home/blocs/push/push_bloc.dart';
import 'package:smart_home/blocs/storage/blocs.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/models/grobal_keys.dart';
import 'package:smart_home/pages/blog/home_page.dart';
import 'package:smart_home/pages/board/home_page.dart';
import 'package:smart_home/pages/iot/home_page.dart';
import 'package:smart_home/pages/login_page.dart';
import 'package:smart_home/pages/splash_page.dart';
import 'package:smart_home/pages/storage/home_page.dart';
import 'package:smart_home/utils/launch_url.dart';

class HomePage extends Page {
  final AppTab defaultPage;

  const HomePage({
    @required this.defaultPage,
  });

  @override
  Route createRoute(BuildContext context) {
    BlocProvider.of<AuthenticationBloc>(context).add(AuthenticationStarted());
    return MaterialPageRoute(
      settings: this,
      builder: (context) => HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is AuthenticationFailure) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
        if (state is AuthenticationSuccess) {
          // 当登录成功时，开始初始化推送服务
          BlocProvider.of<PushBloc>(context).add(PushStarted());
        }
      },
      builder: (context, state) {
        if (state is AuthenticationInitial) {
          return SplashScreen();
        }
        // 仅在登陆失败和登陆中进入登陆界面
        if (state is AuthenticationInProgress ||
            state is AuthenticationFailure) {
          return LoginPage();
        }
        return BlocListener<UpdateBloc, UpdateState>(
          listener: (context, state) {
            if (state is UpdateSuccess && state.needUpdate) {
              scaffoldMessengerKey.currentState.showSnackBar(
                SnackBar(
                  content: Text('发现新版本（${state.version}）'),
                  action: SnackBarAction(
                    label: '更新',
                    onPressed: () {
                      launchUrl(state.url);
                    },
                  ),
                ),
              );
            }
            if (state is UpdateFailure) {
              scaffoldMessengerKey.currentState.showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  action: SnackBarAction(
                    label: '重试',
                    onPressed: () {
                      BlocProvider.of<UpdateBloc>(context).add(UpdateStarted());
                    },
                  ),
                ),
              );
            }
          },
          child: _HomePage(),
        );
      },
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
    return BlocBuilder<TabBloc, AppTab>(
      builder: (context, activeTab) {
        if (activeTab == AppTab.storage) {
          BlocProvider.of<StorageHomeBloc>(context)
              .add(StorageHomeChanged(itemType: ItemType.all));
          return StorageHomePage();
        }
        if (activeTab == AppTab.blog) {
          return BlogHomePage();
        }
        if (activeTab == AppTab.iot) {
          return IotHomePage();
        }
        BlocProvider.of<BoardHomeBloc>(context).add(BoardHomeStarted());
        return BoardHomePage();
      },
    );
  }
}
