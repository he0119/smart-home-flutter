import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class MyTransitionDelegate extends TransitionDelegate<void> {
  static final Logger _log = Logger('TransitionDelegate');
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
    _log.fine('newPageRouteHistory: $newPageRouteHistory');
    _log.fine('locationToExitingPageRoute: $locationToExitingPageRoute');
    // 主页之间的切换，不需要动画
    // 从启动界面或者登录界面进入主页，也不需要动画
    if (newPageRouteHistory.length == 1 &&
        locationToExitingPageRoute.length == 1) {
      final exitingRoute = locationToExitingPageRoute.values.last;
      final newRoute = newPageRouteHistory.last;
      if (exitingRoute.route.settings.name != null &&
          exitingRoute.route.settings.name
              .startsWith(RegExp(r'^/(AppTab|splash|login)')) &&
          newRoute.route.settings.name != null &&
          newRoute.route.settings.name.startsWith('/AppTab')) {
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
