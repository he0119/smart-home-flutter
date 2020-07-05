import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/pages/board/home_page.dart';
import 'package:smart_home/pages/login_page.dart';
import 'package:smart_home/pages/splash_page.dart';
import 'package:smart_home/pages/storage/home_page.dart';
import 'package:smart_home/pages/storage/search_page.dart';
import 'package:smart_home/pages/storage/storage_datail_page.dart';
import 'package:smart_home/repositories/board_repository.dart';
import 'package:smart_home/repositories/graphql_api_client.dart';
import 'package:smart_home/repositories/storage_repository.dart';
import 'package:smart_home/repositories/user_repository.dart';
import 'package:smart_home/repositories/version_repository.dart';
import 'package:smart_home/widgets/show_snack_bar.dart';
import 'package:smart_home/widgets/tab_selector.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<UserRepository>(
          create: (context) => UserRepository(
            graphqlApiClient: RepositoryProvider.of<GraphQLApiClient>(context),
          ),
        ),
        RepositoryProvider<VersionRepository>(
          create: (context) => VersionRepository(),
        ),
      ],
      child: BlocProvider(
        create: (context) => AuthenticationBloc(
          userRepository: RepositoryProvider.of<UserRepository>(context),
          graphqlApiClient: RepositoryProvider.of<GraphQLApiClient>(context),
        )..add(AuthenticationStarted()),
        child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            if (state is Unauthenticated) {
              return LoginPage();
            }
            if (state is Authenticated) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider<TabBloc>(
                    create: (context) => TabBloc(),
                  ),
                  BlocProvider<SnackBarBloc>(
                    create: (context) => SnackBarBloc(),
                  ),
                  BlocProvider<UpdateBloc>(
                    create: (context) => UpdateBloc(
                      versionRepository:
                          RepositoryProvider.of<VersionRepository>(context),
                    ),
                  ),
                ],
                child: _HomePage(),
              );
            }
            return SplashPage();
          },
        ),
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
        return Scaffold(
          appBar: _buildAppBar(context, activeTab),
          body: MultiBlocListener(
            listeners: [
              BlocListener<SnackBarBloc, SnackBarState>(
                listenWhen: (previous, current) {
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
                              await _launchUrl(state.url);
                            },
                          )
                        ],
                      ),
                    );
                  }
                },
              ),
              BlocListener<TabBloc, AppTab>(
                listenWhen: (previous, current) {
                  // 仅在 Web 上自动转跳到对应网页
                  if (!kIsWeb) {
                    return false;
                  }
                  return true;
                },
                listener: (context, activeTab) async {
                  if (activeTab == AppTab.blog) {
                    await _launchUrl('https://hehome.xyz');
                  }
                  if (activeTab == AppTab.iot) {
                    await _launchUrl('https://iot.hehome.xyz');
                  }
                },
              )
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
      return RepositoryProvider(
          create: (context) => StorageRepository(
                graphqlApiClient:
                    RepositoryProvider.of<GraphQLApiClient>(context),
              ),
          child: StorageHomePage());
    }
    if (activeTab == AppTab.iot) {
      const String url = 'https://iot.hehome.xyz';
      return !kIsWeb
          ? WebView(
              key: UniqueKey(),
              initialUrl: url,
              javascriptMode: JavascriptMode.unrestricted,
            )
          : Center(
              child: RaisedButton(
                onPressed: () => _launchUrl(url),
                child: Text('IOT'),
              ),
            );
    }
    if (activeTab == AppTab.blog) {
      const String url = 'https://hehome.xyz';
      return !kIsWeb
          ? WebView(
              key: UniqueKey(),
              initialUrl: url,
              javascriptMode: JavascriptMode.unrestricted,
            )
          : Center(
              child: RaisedButton(
                onPressed: () => _launchUrl(url),
                child: Text('博客'),
              ),
            );
    }
    return RepositoryProvider(
      create: (context) => BoardRepository(
        graphqlApiClient: RepositoryProvider.of<GraphQLApiClient>(context),
      ),
      child: BoardHomePage(),
    );
  }

  FloatingActionButton _buildFloatingActionButton(
      BuildContext context, AppTab activeTab) {
    if (activeTab == AppTab.blog) {
      return FloatingActionButton(
        child: Icon(Icons.open_in_new),
        onPressed: () async {
          const url = 'https://hehome.xyz';
          await _launchUrl(url);
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
    if (activeTab == AppTab.board) {
      return FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          // TODO: 添加页面转跳逻辑
        },
      );
    }
    return null;
  }

  Future _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
