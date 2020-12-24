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

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// 是否初始化
  bool initialized = false;

  /// 是否登录
  bool isLogin = false;

  AppTab defaultPage;

  RoutePath get configuration => _configuration;
  RoutePath _configuration;
  set configuration(RoutePath routePath) {
    _configuration = routePath;
    notifyListeners();
  }

  @override
  Future<void> setNewRoutePath(RoutePath configuration) async {
    _configuration = configuration;
  }

  // For web application
  @override
  RoutePath get currentConfiguration => configuration;

  bool _handlePopPage(Route<dynamic> route, dynamic result) {
    final bool success = route.didPop(result);
    if (success) {
      notifyListeners();
    }
    return success;
  }

  @override
  Widget build(BuildContext context) {
    final currentAppPath = configuration;
    _log.fine('Router rebuilded');
    _log.fine('currentAppPath: $currentAppPath');
    _log.fine('initialized: $initialized');
    _log.fine('isLogin: $isLogin');
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
              defaultPage = state.defaultPage;
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
              configuration = AppRoutePath(appTab: state);
            }
          },
        )
      ],
      child: Navigator(
        key: navigatorKey,
        pages: initialized
            ? isLogin
                ? <Page>[
                    if (currentAppPath is AppRoutePath)
                      HomePage(appTab: currentAppPath.appTab ?? defaultPage),
                  ]
                : [LoginPage()]
            : [
                SplashPage(),
              ],
        onPopPage: _handlePopPage,
      ),
    );
  }
}
