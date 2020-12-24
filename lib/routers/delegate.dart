import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:smart_home/app_config.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/pages/home_page.dart';
import 'package:smart_home/pages/login_page.dart';
import 'package:smart_home/pages/splash_page.dart';
import 'package:smart_home/repositories/repositories.dart';
import 'package:smart_home/routers/route_path.dart';

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
    _log.fine('configuration $routePath');
    if (!initialized) {
      _pages = [SplashPage()];
      return _pages;
    }
    if (!isLogin) {
      _pages = [LoginPage()];
      return _pages;
    }
    final current = routePath;
    if (current is AppRoutePath) {
      if (current.appTab == null) {
        _routePath = AppRoutePath(appTab: defaultHomePage);
        currentHomePage = defaultHomePage;
        _pages = [HomePage(appTab: currentHomePage)];
      }
    }
    _log.fine('pages $_pages');
    return List.unmodifiable(_pages);
  }

  RoutePath get routePath => _routePath;
  RoutePath _routePath;
  set routePath(RoutePath routePath) {
    if (routePath is AppRoutePath) {
      _routePath = routePath;
      currentHomePage = routePath.appTab;
    }
    notifyListeners();
  }

  @override
  Future<void> setNewRoutePath(RoutePath routePath) async {
    _routePath = routePath;
  }

  // For web application
  @override
  RoutePath get currentConfiguration => routePath;

  bool _handlePopPage(Route<dynamic> route, dynamic result) {
    final bool success = route.didPop(result);
    if (success) {
      _pages.remove(route.settings);
      notifyListeners();
    }
    return success;
  }

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
              routePath = AppRoutePath(appTab: state);
              notifyListeners();
            }
          },
        )
      ],
      child: Navigator(
        key: navigatorKey,
        pages: pages,
        onPopPage: _handlePopPage,
      ),
    );
  }
}
