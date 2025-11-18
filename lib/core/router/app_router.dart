import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/widgets/tab_selector.dart';

// 路由路径常量
class AppRoutes {
  static const String login = '/login';
  static const String home = '/';
  static const String storage = '/storage';
  static const String storageDetail = '/storage/:id';
  static const String itemDetail = '/item/:id';
  static const String topicDetail = '/topic/:id';
  static const String pictureDetail = '/picture/:id';
  static const String consumables = '/consumables';
  static const String recycleBin = '/recyclebin';
  static const String settings = '/settings';
  static const String blogSettings = '/settings/blog';
  static const String blog = '/blog';
  static const String board = '/board';
}

// 路由守卫
class AuthGuard extends StatelessWidget {
  final Widget child;
  final bool isLogin;

  const AuthGuard({
    super.key,
    required this.child,
    required this.isLogin,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLogin) {
      // 如果未登录，重定向到登录页面
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(AppRoutes.login);
      });
      return const SizedBox.shrink();
    }
    return child;
  }
}

// 自定义路由转换
CustomTransitionPage<T> buildPageWithDefaultTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

// 主页面的Shell路由
class HomeShell extends ConsumerWidget {
  final Widget child;
  final String location;

  const HomeShell({
    super.key,
    required this.child,
    required this.location,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: child,
      bottomNavigationBar: TabSelector(
        activeTab: _getCurrentTab(location),
        onTabSelected: (tab) {
          // 使用go_router进行导航
          switch (tab) {
            case AppTab.storage:
              context.go('/storage');
              break;
            case AppTab.blog:
              context.go('/blog');
              break;
            case AppTab.board:
              context.go('/board');
              break;
          }
        },
      ),
    );
  }

  AppTab _getCurrentTab(String location) {
    if (location.startsWith('/storage')) return AppTab.storage;
    if (location.startsWith('/blog')) return AppTab.blog;
    if (location.startsWith('/board')) return AppTab.board;
    return AppTab.storage;
  }
}