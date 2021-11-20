import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:smarthome/blog/blog.dart';
import 'package:smarthome/board/board.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/core/settings/settings_controller.dart';
import 'package:smarthome/iot/iot.dart';
import 'package:smarthome/routers/information_parser.dart';
import 'package:smarthome/routers/route_path.dart';
import 'package:smarthome/storage/storage.dart';
import 'package:smarthome/utils/launch_url.dart';

class MyRouterDelegate extends RouterDelegate<RoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RoutePath> {
  static final Logger _log = Logger('RouterDelegate');

  final SettingsController settingsController;

  MyRouterDelegate({
    required this.settingsController,
  });

  static MyRouterDelegate of(BuildContext context) {
    final delegate = Router.of(context).routerDelegate;
    assert(delegate is MyRouterDelegate, 'Delegate type must match');
    return delegate as MyRouterDelegate;
  }

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// 默认主页
  AppTab defaultHomePage = AppTab.storage;

  List<Page> _pages = <Page>[];

  List<Page> get pages {
    // 未登录时显示登陆界面
    if (!settingsController.isLogin) {
      return [const LoginPage()];
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
  void addStorageGroup({Storage? storage}) {
    storageGroup += 1;
    _pages.add(
      StorageDetailPage(
        storageId: storage?.id ?? '',
        group: storageGroup,
      ),
    );
    notifyListeners();
  }

  /// 物品位置页面间的导航
  void setStoragePage({Storage? storage}) {
    // 先从最后开始删除当前的物品位置页面
    // 一直删除到这一组结束
    // 每次只删除一个 Group
    while (_pages.last is StorageDetailPage &&
        _pages.last.name!.startsWith('/storage/$storageGroup')) {
      _pages.removeLast();
    }
    // 再重新添加
    _pages.add(StorageDetailPage(storageId: '', group: storageGroup));
    if (storage != null) {
      if (storage.ancestors != null) {
        for (var storage in storage.ancestors!) {
          _pages.add(
            StorageDetailPage(
              storageId: storage.id,
              group: storageGroup,
            ),
          );
        }
      }
      _pages.add(
        StorageDetailPage(
          storageId: storage.id,
          group: storageGroup,
        ),
      );
    }
    notifyListeners();
  }

  int itemCount = 0;

  /// 添加一个物品详情页面
  void addItemPage({required Item item}) {
    itemCount += 1;
    _pages.add(
      ItemDetailPage(
        itemId: item.id,
        group: itemCount,
      ),
    );
    notifyListeners();
  }

  Future<void> navigateNewPath(String url) async {
    final routePath = parseUrl(url);
    await setNewRoutePath(routePath);
    notifyListeners();
  }

  bool _handlePopPage(Route<dynamic> route, dynamic result) {
    final success = route.didPop(result);
    if (success) {
      _log.fine('Pop ${route.settings.name}');
      _pages.remove(route.settings);
      // 每当一组位置全部 Pop，Group 计数减一
      if (route.settings.name!.startsWith('/storage')) {
        if (!_pages.last.name!.startsWith('/storage/$storageGroup')) {
          storageGroup -= 1;
        }
      }
      if (route.settings.name!.startsWith('/item')) {
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
      final uri = Uri.parse(pages.last.name!);
      if (pages.last is IotHomePage ||
          pages.last is BoardHomePage ||
          pages.last is BlogHomePage ||
          pages.last is StorageHomePage) {
        return HomeRoutePath(
          appTab: EnumToString.fromString(AppTab.values, uri.pathSegments[0]),
        );
      } else if (pages.last is StorageDetailPage) {
        return StorageRoutePath(storageId: uri.pathSegments[2]);
      } else if (pages.last is ItemDetailPage) {
        return ItemRoutePath(itemId: uri.pathSegments[1]);
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
  Future<void> setNewRoutePath(RoutePath? configuration) async {
    _log.fine('setNewRoutePath: $configuration');
    if (configuration is HomeRoutePath) {
      final appTab = configuration.appTab;
      if (appTab != null) {
        _pages = [appTab.page];
      }
    } else if (configuration is TopicRoutePath) {
      _pages = [
        const BoardHomePage(),
        TopicDetailPage(topicId: configuration.topicId),
      ];
    } else if (configuration is ItemRoutePath) {
      storageGroup = 0;
      itemCount = 1;
      _pages = [
        const StorageHomePage(),
        ItemDetailPage(
          itemId: configuration.itemId,
          group: 1,
        ),
      ];
    } else if (configuration is StorageRoutePath) {
      storageGroup = 1;
      itemCount = 0;
      _pages = [
        const StorageHomePage(),
        StorageDetailPage(
          storageId: configuration.storageId,
          group: 1,
        ),
      ];
    } else if (configuration is AppRoutePath) {
      switch (configuration.appPage) {
        case AppPage.login:
          break;
        case AppPage.consumables:
          _pages = [
            const StorageHomePage(),
            ConsumablesPage(),
          ];
          break;
        case AppPage.recycleBin:
          _pages = [
            const StorageHomePage(),
            RecycleBinPage(),
          ];
          break;
      }
    } else if (configuration is SettingsRoutePath) {
      switch (configuration.appSettings) {
        case AppSettings.home:
          _pages = [
            defaultHomePage.page,
            const SettingsPage(),
          ];
          break;
        case AppSettings.iot:
          _pages = [
            const IotHomePage(),
            const IotSettingsPage(),
          ];
          break;
        case AppSettings.blog:
          _pages = [
            const BlogHomePage(),
            const BlogSettingsPage(),
          ];
          break;
        default:
      }
    } else if (configuration is PictureRoutePath) {
      _pages = [
        const StorageHomePage(),
        PicturePage(pictureId: configuration.pictureId),
      ];
    }
  }

  // TransitionDelegate transitionDelegate = MyTransitionDelegate();

  @override
  Widget build(BuildContext context) {
    _log
      ..fine('Router rebuilded')
      ..fine('pages $pages');

    return MultiBlocListener(
      listeners: [
        BlocListener<AuthenticationBloc, AuthenticationState>(
          listener: (context, state) {
            if (state is AuthenticationFailure) {
              // 清除 Sentry 设置的用户
              Sentry.configureScope((scope) => scope.user = null);
              // 登录状态变化，通知页面更新
              notifyListeners();
            }
            if (state is AuthenticationSuccess) {
              // 当登录成功时，开始初始化推送服务
              BlocProvider.of<PushBloc>(context).add(PushStarted());
              // 设置 Sentry 用户
              Sentry.configureScope(
                (scope) => scope.user = SentryUser(
                  id: state.currentUser.username,
                  email: state.currentUser.email,
                ),
              );
              notifyListeners();
            }
          },
        ),
        BlocListener<TabBloc, AppTab?>(
          listener: (context, state) {
            if (state != null) {
              setHomePage(state);
            }
          },
        ),
        BlocListener<UpdateBloc, UpdateState>(
          listener: (context, state) {
            if (state is UpdateSuccess && state.needUpdate) {
              scaffoldMessengerKey.currentState!.showSnackBar(
                SnackBar(
                  content: Text('发现新版本（${state.version}）'),
                  action: SnackBarAction(
                    label: '更新',
                    onPressed: () {
                      launchUrl(state.url!);
                    },
                  ),
                ),
              );
            }
            if (state is UpdateFailure) {
              scaffoldMessengerKey.currentState!.showSnackBar(
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
        // transitionDelegate: transitionDelegate,
      ),
    );
  }
}
