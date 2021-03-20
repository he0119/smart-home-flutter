import 'dart:io';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:smarthome/app_config.dart';
import 'package:smarthome/blocs/core/blocs.dart';
import 'package:smarthome/models/grobal_keys.dart';
import 'package:smarthome/models/models.dart';
import 'package:smarthome/pages/blog/home_page.dart';
import 'package:smarthome/pages/board/home_page.dart';
import 'package:smarthome/pages/board/topic_detail_page.dart';
import 'package:smarthome/pages/iot/home_page.dart';
import 'package:smarthome/pages/login_page.dart';
import 'package:smarthome/pages/settings/blog/settings_page.dart';
import 'package:smarthome/pages/settings/iot/settings_page.dart';
import 'package:smarthome/pages/settings/settings_page.dart';
import 'package:smarthome/pages/splash_page.dart';
import 'package:smarthome/pages/storage/consumables_page.dart';
import 'package:smarthome/pages/storage/home_page.dart';
import 'package:smarthome/pages/storage/item_datail_page.dart';
import 'package:smarthome/pages/storage/picture_page.dart';
import 'package:smarthome/pages/storage/recycle_bin_page.dart';
import 'package:smarthome/pages/storage/storage_datail_page.dart';
import 'package:smarthome/repositories/repositories.dart';
import 'package:smarthome/routers/information_parser.dart';
import 'package:smarthome/routers/route_path.dart';
import 'package:smarthome/routers/transition_delegate.dart';
import 'package:smarthome/utils/launch_url.dart';

class MyRouterDelegate extends RouterDelegate<RoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RoutePath> {
  static final Logger _log = Logger('RouterDelegate');

  static MyRouterDelegate of(BuildContext context) {
    final delegate = Router.of(context).routerDelegate;
    assert(delegate is MyRouterDelegate, 'Delegate type must match');
    return delegate as MyRouterDelegate;
  }

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// 是否初始化
  bool initialized = false;

  /// 是否登录
  bool isLogin = false;

  /// 默认主页
  AppTab defaultHomePage;

  List<Page> _pages = <Page>[];

  List<Page> get pages {
    // 未初始化时显示加载页面
    if (!initialized) {
      return [SplashPage()];
    }
    // 未登录时显示登陆界面
    if (!isLogin) {
      return [LoginPage()];
    }
    // 未设置主页时显示默认主页
    if (_pages.isEmpty) {
      _pages = [
        defaultHomePage.page,
      ];
    }
    return List.unmodifiable(_pages);
  }

  void push(Page newPage) {
    _pages.add(newPage);
    notifyListeners();
  }

  void pop() {
    if (_pages.isNotEmpty) {
      _pages.remove(_pages.last);
    }
    notifyListeners();
  }

  /// 设置主页
  void setHomePage(AppTab appTab) {
    _pages = [appTab.page];
    notifyListeners();
  }

  // 记录当前位置组的数量
  int storageGroup = 0;

  /// 添加一组位置
  void addStorageGroup({Storage storage}) {
    storageGroup += 1;
    _pages.add(StorageDetailPage(
      storageName: storage?.name ?? '',
      storageId: storage?.id,
      group: storageGroup,
    ));
    notifyListeners();
  }

  /// 物品位置页面间的导航
  void setStoragePage({Storage storage}) {
    // 先从最后开始删除当前的物品位置页面
    // 一直删除到这一组结束
    // 每次只删除一个 Group
    while (_pages.last is StorageDetailPage &&
        _pages.last.name.startsWith('/storage/$storageGroup')) {
      _pages.removeLast();
    }
    // 再重新添加
    _pages.add(StorageDetailPage(storageName: '', group: storageGroup));
    if (storage != null) {
      if (storage.ancestors != null) {
        for (Storage storage in storage.ancestors) {
          _pages.add(StorageDetailPage(
            storageName: storage.name,
            storageId: storage.id,
            group: storageGroup,
          ));
        }
      }
      _pages.add(StorageDetailPage(
        storageName: storage.name,
        storageId: storage.id,
        group: storageGroup,
      ));
    }
    notifyListeners();
  }

  int itemCount = 0;

  /// 添加一个物品详情页面
  void addItemPage({@required Item item}) {
    itemCount += 1;
    _pages.add(ItemDetailPage(
      itemName: item.name,
      itemId: item.id,
      group: itemCount,
    ));
    notifyListeners();
  }

  Future<void> navigateNewPath(String url) async {
    final routePath = parseUrl(url);
    await setNewRoutePath(routePath);
    notifyListeners();
  }

  bool _handlePopPage(Route<dynamic> route, dynamic result) {
    final bool success = route.didPop(result);
    if (success) {
      _log.fine('Pop ${route.settings.name}');
      _pages.remove(route.settings);
      // 每当一组位置全部 Pop，Group 计数减一
      if (route.settings.name.startsWith('/storage')) {
        if (!_pages.last.name.startsWith('/storage/$storageGroup')) {
          storageGroup -= 1;
        }
      }
      if (route.settings.name.startsWith('/item')) {
        itemCount -= 1;
      }
      notifyListeners();
    }
    return success;
  }

  // 网页版显示网址
  @override
  RoutePath get currentConfiguration => routePath;

  /// 从当前显示页面倒推 RoutePath
  RoutePath get routePath {
    if (pages.last.name != null) {
      final uri = Uri.parse(pages.last.name);
      if (pages.last is IotHomePage ||
          pages.last is BoardHomePage ||
          pages.last is BlogHomePage ||
          pages.last is StorageHomePage) {
        return HomeRoutePath(
          appTab: EnumToString.fromString(AppTab.values, uri.pathSegments[0]),
        );
      } else if (pages.last is StorageDetailPage) {
        return StorageRoutePath(storageName: uri.pathSegments[2]);
      } else if (pages.last is ItemDetailPage) {
        return ItemRoutePath(itemName: uri.pathSegments[1]);
      } else if (pages.last is TopicDetailPage) {
        return TopicRoutePath(topicId: uri.pathSegments[1]);
      } else if (pages.last is LoginPage) {
        return AppRoutePath(AppPage.login);
      } else if (pages.last is ConsumablesPage) {
        return AppRoutePath(AppPage.consumables);
      } else if (pages.last is RecycleBinPage) {
        return AppRoutePath(AppPage.recycleBin);
      } else if (pages.last is SettingsPage) {
        return SettingsRoutePath(appSettings: AppSettings.home);
      } else if (pages.last is BlogSettingsPage) {
        return SettingsRoutePath(appSettings: AppSettings.blog);
      } else if (pages.last is IotSettingsPage) {
        return SettingsRoutePath(appSettings: AppSettings.iot);
      } else if (pages.last is PicturePage) {
        return PictureRoutePath(pictureId: uri.pathSegments[1]);
      }
    }
    return HomeRoutePath();
  }

  @override
  Future<void> setNewRoutePath(RoutePath routePath) async {
    _log.fine('setNewRoutePath: $routePath');
    if (routePath is HomeRoutePath && routePath.appTab != null) {
      _pages = [routePath.appTab.page];
    } else if (routePath is TopicRoutePath) {
      _pages = [
        BoardHomePage(),
        TopicDetailPage(topicId: routePath.topicId),
      ];
    } else if (routePath is ItemRoutePath) {
      storageGroup = 0;
      itemCount = 1;
      _pages = [
        StorageHomePage(),
        ItemDetailPage(
          itemName: routePath.itemName,
          itemId: routePath.itemId,
          group: 1,
        ),
      ];
    } else if (routePath is StorageRoutePath) {
      storageGroup = 1;
      itemCount = 0;
      _pages = [
        StorageHomePage(),
        StorageDetailPage(
          storageName: routePath.storageName,
          storageId: routePath.storageId,
          group: 1,
        ),
      ];
    } else if (routePath is AppRoutePath) {
      switch (routePath.appPage) {
        case AppPage.login:
          break;
        case AppPage.consumables:
          _pages = [
            StorageHomePage(),
            ConsumablesPage(),
          ];
          break;
        case AppPage.recycleBin:
          _pages = [
            StorageHomePage(),
            RecycleBinPage(),
          ];
          break;
      }
    } else if (routePath is SettingsRoutePath) {
      switch (routePath.appSettings) {
        case AppSettings.home:
          _pages = [
            defaultHomePage.page,
            SettingsPage(),
          ];
          break;
        case AppSettings.iot:
          _pages = [
            IotHomePage(),
            IotSettingsPage(),
          ];
          break;
        case AppSettings.blog:
          _pages = [
            BlogHomePage(),
            BlogSettingsPage(),
          ];
          break;
      }
    } else if (routePath is PictureRoutePath) {
      _pages = [
        StorageHomePage(),
        PicturePage(pictureId: routePath.pictureId),
      ];
    }
  }

  TransitionDelegate transitionDelegate = MyTransitionDelegate();

  @override
  Widget build(BuildContext context) {
    _log.fine('Router rebuilded');
    _log.fine('pages $pages');
    final graphQLApiClient = RepositoryProvider.of<GraphQLApiClient>(context);
    final AppConfig config = AppConfig.of(context);
    return MultiBlocListener(
      listeners: [
        BlocListener<AppPreferencesBloc, AppPreferencesState>(
          listenWhen: (previous, current) {
            // 如果 APIURL 发生变化则初始化 GraphQL 客户端
            // 如果客户端还未初始化，也自动初始化
            if (previous.apiUrl != current.apiUrl ||
                graphQLApiClient.client == null) {
              return true;
            } else {
              return false;
            }
          },
          listener: (context, state) async {
            // 如果软件配置中没有设置过 APIURL，则使用默认的 URL
            await graphQLApiClient.initailize(state.apiUrl ?? config.apiUrl);
            if (state.initialized) {
              initialized = state.initialized;
              isLogin = state.loginUser != null;
              defaultHomePage = state.defaultPage;
              // GraphQL 客户端初始化后，开始认证用户
              BlocProvider.of<AuthenticationBloc>(context)
                  .add(AuthenticationStarted());
              // 仅在客户端上注册 Shortcut
              if (!kIsWeb && !Platform.isWindows) {
                final QuickActions quickActions = QuickActions();
                quickActions.initialize((String shortcutType) async {
                  if (shortcutType == 'action_iot') {
                    BlocProvider.of<TabBloc>(context)
                        .add(TabChanged(AppTab.iot));
                  } else if (shortcutType == 'action_storage') {
                    BlocProvider.of<TabBloc>(context)
                        .add(TabChanged(AppTab.storage));
                  } else if (shortcutType == 'action_blog') {
                    BlocProvider.of<TabBloc>(context)
                        .add(TabChanged(AppTab.blog));
                  } else {
                    BlocProvider.of<TabBloc>(context)
                        .add(TabChanged(AppTab.board));
                  }
                });
                quickActions.setShortcutItems(
                  <ShortcutItem>[
                    // TODO: 给快捷方式添加图标
                    const ShortcutItem(
                        type: 'action_iot', localizedTitle: 'IOT'),
                    const ShortcutItem(
                        type: 'action_storage', localizedTitle: '物品'),
                    const ShortcutItem(
                        type: 'action_blog', localizedTitle: '博客'),
                    const ShortcutItem(
                        type: 'action_board', localizedTitle: '留言'),
                  ],
                );
              }
              notifyListeners();
            }
          },
        ),
        BlocListener<AuthenticationBloc, AuthenticationState>(
          listener: (context, state) {
            if (state is AuthenticationFailure) {
              isLogin = false;
              notifyListeners();
            }
            if (state is AuthenticationSuccess) {
              isLogin = true;
              // 当登录成功时，开始初始化推送服务
              BlocProvider.of<PushBloc>(context).add(PushStarted());
              notifyListeners();
            }
          },
        ),
        BlocListener<TabBloc, AppTab>(
          listener: (context, state) {
            if (state != null) {
              setHomePage(state);
            }
          },
        ),
        BlocListener<UpdateBloc, UpdateState>(
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
        ),
      ],
      child: Navigator(
        key: navigatorKey,
        pages: pages,
        onPopPage: _handlePopPage,
        transitionDelegate: transitionDelegate,
      ),
    );
  }
}
