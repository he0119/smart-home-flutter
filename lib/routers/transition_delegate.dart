import 'package:flutter/material.dart';
import 'package:smart_home/pages/home_page.dart';
import 'package:smart_home/pages/login_page.dart';
import 'package:smart_home/pages/splash_page.dart';

class MyTransitionDelegate extends TransitionDelegate<void> {
  final defaultTransitionDelegate = DefaultTransitionDelegate();

  @override
  Iterable<RouteTransitionRecord> resolve({
    List<RouteTransitionRecord> newPageRouteHistory,
    Map<RouteTransitionRecord, RouteTransitionRecord>
        locationToExitingPageRoute,
    Map<RouteTransitionRecord, List<RouteTransitionRecord>>
        pageRouteToPagelessRoutes,
  }) {
    final List<RouteTransitionRecord> results = <RouteTransitionRecord>[];
    // 主页之间的切换，不需要动画
    // 从启动界面或者登录界面进入主页，也不需要动画
    if (newPageRouteHistory.length == 1 &&
        locationToExitingPageRoute.length == 1) {
      final exitingRoute = locationToExitingPageRoute.values.last;
      final newRoute = newPageRouteHistory.last;
      if ((exitingRoute.route.settings is HomePage ||
              exitingRoute.route.settings is LoginPage ||
              exitingRoute.route.settings is SplashPage) &&
          newRoute.route.settings is HomePage) {
        exitingRoute.markForRemove();
        newRoute.markForAdd();
        results.add(exitingRoute);
        results.add(newRoute);
        return results;
      }
    }

    // 如果不是特殊情况，按照默认处理
    results.addAll(defaultTransitionDelegate.resolve(
      newPageRouteHistory: newPageRouteHistory,
      locationToExitingPageRoute: locationToExitingPageRoute,
      pageRouteToPagelessRoutes: pageRouteToPagelessRoutes,
    ));

    return results;
  }
}
