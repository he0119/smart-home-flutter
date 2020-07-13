import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/blocs/board/blocs.dart';
import 'package:smart_home/blocs/storage/blocs.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/models/grobal_keys.dart';
import 'package:smart_home/pages/blog/home_page.dart';
import 'package:smart_home/pages/board/home_page.dart';
import 'package:smart_home/pages/iot/home_page.dart';
import 'package:smart_home/pages/login_page.dart';
import 'package:smart_home/pages/splash_page.dart';
import 'package:smart_home/pages/storage/home_page.dart';
import 'package:smart_home/repositories/repositories.dart';
import 'package:smart_home/utils/launch_url.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthenticationBloc(
        userRepository: RepositoryProvider.of<UserRepository>(context),
      )..add(AuthenticationStarted()),
      child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state is AuthenticationUninitialized) {
            RepositoryProvider.of<UserRepository>(context).authenticationBloc =
                BlocProvider.of<AuthenticationBloc>(context);
            return SplashPage();
          }
          // 仅在未登录或登陆失败时进入登陆界面
          if (state is Unauthenticated ||
              state is Authenticating ||
              state is AuthenticationFailure) {
            return LoginPage();
          }
          return BlocListener<UpdateBloc, UpdateState>(
            listener: (context, state) {
              if (state is UpdateSuccess && state.needUpdate) {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text('更新'),
                    content: Text('发现新版本（${state.version}）'),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('稍后'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      FlatButton(
                        child: Text('下载'),
                        onPressed: () async {
                          Navigator.pop(context);
                          launchUrl(state.url);
                        },
                      )
                    ],
                  ),
                );
              }
              if (state is UpdateFailure) {
                scaffoldKey.currentState.showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    action: SnackBarAction(
                      label: '重试',
                      onPressed: () {
                        BlocProvider.of<UpdateBloc>(context)
                            .add(UpdateStarted());
                      },
                    ),
                  ),
                );
              }
            },
            child: _HomePage(),
          );
        },
      ),
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage({Key key}) : super(key: key);

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
        if (activeTab == AppTab.storage) {
          BlocProvider.of<StorageHomeBloc>(context).add(StorageHomeStarted());
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
