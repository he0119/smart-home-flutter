import 'package:flutter/material.dart';

import 'package:smart_home/models/app_tab.dart';
import 'package:smart_home/routers/route_path.dart';

class MyRouteInformationParser extends RouteInformationParser<RoutePath> {
  @override
  Future<RoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    final String routeName = routeInformation.location;

    return AppRoutePath(appTab: AppTab.iot);
    throw 'unknown';
  }

  @override
  RouteInformation restoreRouteInformation(RoutePath routePath) {
    if (routePath is AppRoutePath) {
      switch (routePath.appTab) {
        case AppTab.blog:
          return const RouteInformation(location: '/blog');
        case AppTab.iot:
          return const RouteInformation(location: '/iot');
        case AppTab.storage:
          return const RouteInformation(location: '/storage');
          break;
        case AppTab.board:
          return const RouteInformation(location: '/board');
          break;
      }
    }
    throw 'unknown';
  }
}
