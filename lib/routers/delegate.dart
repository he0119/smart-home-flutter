import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:smart_home/app_config.dart';
import 'package:smart_home/blocs/core/blocs.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/pages/board/topic_detail_page.dart';
import 'package:smart_home/pages/home_page.dart';
import 'package:smart_home/pages/login_page.dart';
import 'package:smart_home/pages/splash_page.dart';
import 'package:smart_home/pages/storage/item_datail_page.dart';
import 'package:smart_home/pages/storage/storage_datail_page.dart';
import 'package:smart_home/repositories/repositories.dart';
import 'package:smart_home/routers/route_path.dart';
import 'package:smart_home/routers/transition_delegate.dart';

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

  /// 当前主页
  AppTab currentHomePage;

  /// 默认主页
  AppTab defaultHomePage;

  List<Page> _pages = <Page>[];

  List<Page> get pages {
    _log.fine('Router rebuilded');
    if (!initialized) {
      _pages = [
        SplashPage(),
      ];
      return _pages;
    }
    if (!isLogin) {
      _pages = [
        LoginPage(),
      ];
      return _pages;
    }
    if (_pages.isEmpty || _pages.length == 1) {
      _pages = [
        HomePage(appTab: currentHomePage ?? defaultHomePage),
      ];
    }
    _log.fine('pages $_pages');
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

  bool _handlePopPage(Route<dynamic> route, dynamic result) {
    final bool success = route.didPop(result);
    if (success) {
      _log.fine('pop ${route.settings.name}');
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
    if (_pages.isNotEmpty && _pages.last.name != null) {
      final uri = Uri.parse(_pages.last.name);
      if (_pages.last is HomePage) {
        return AppRoutePath(appTab: currentHomePage);
      } else if (_pages.last is StorageDetailPage) {
        return StorageRoutePath(storageName: uri.pathSegments[1]);
      } else if (_pages.last is ItemDetailPage) {
        return ItemRoutePath(itemName: uri.pathSegments[1]);
      } else if (_pages.last is TopicDetailPage) {
        return TopicRoutePath(topicId: uri.pathSegments[1]);
      }
    }
    return AppRoutePath();
  }

  @override
  Future<void> setNewRoutePath(RoutePath routePath) async {
    _log.fine('setNewRoutePath: $routePath');
    if (routePath is AppRoutePath) {
      _pages = [HomePage(appTab: routePath.appTab)];
    }
    if (routePath is TopicRoutePath) {
      _pages = [
        HomePage(appTab: AppTab.board),
        TopicDetailPage(topicId: routePath.topicId),
      ];
    }
    if (routePath is ItemRoutePath) {
      storageGroup = 0;
      itemCount = 1;
      _pages = [
        HomePage(appTab: AppTab.storage),
        ItemDetailPage(
          itemName: routePath.itemName,
          itemId: routePath.itemId,
          group: 1,
        ),
      ];
    }
    if (routePath is StorageRoutePath) {
      storageGroup = 1;
      itemCount = 0;
      _pages = [
        HomePage(appTab: AppTab.storage),
        StorageDetailPage(
          storageName: routePath.storageName,
          storageId: routePath.storageId,
          group: 1,
        ),
      ];
    }
  }

  TransitionDelegate transitionDelegate = MyTransitionDelegate();

  @override
  Widget build(BuildContext context) {
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
          listener: (context, state) {
            // 如果软件配置中没有设置过 APIURL，则使用默认的 URL
            graphQLApiClient.initailize(state.apiUrl ?? config.apiUrl);
            if (state.initialized) {
              initialized = state.initialized;
              isLogin = state.loginUser != null;
              defaultHomePage = state.defaultPage;
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
              notifyListeners();
            }
          },
        ),
        BlocListener<TabBloc, AppTab>(
          listener: (context, state) {
            if (state != null) {
              currentHomePage = state;
              notifyListeners();
            }
          },
        )
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
