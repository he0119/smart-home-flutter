import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:smart_home/models/app_tab.dart';
import 'package:smart_home/routers/route_path.dart';

class MyRouteInformationParser extends RouteInformationParser<RoutePath> {
  static final Logger _log = Logger('InformationParser');

  @override
  Future<RoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    _log.fine('parseRouteInformation: ${routeInformation.location}');
    return parseUrl(routeInformation.location);
  }

  @override
  RouteInformation restoreRouteInformation(RoutePath routePath) {
    _log.fine('restoreRouteInformation: $routePath');
    if (routePath is HomeRoutePath) {
      switch (routePath.appTab) {
        case AppTab.blog:
          return const RouteInformation(location: '/blog');
        case AppTab.iot:
          return const RouteInformation(location: '/iot');
        case AppTab.storage:
          return const RouteInformation(location: '/storage');
        case AppTab.board:
          return const RouteInformation(location: '/board');
      }
    } else if (routePath is StorageRoutePath) {
      return RouteInformation(location: '/storage/${routePath.storageName}');
    } else if (routePath is ItemRoutePath) {
      return RouteInformation(location: '/item/${routePath.itemName}');
    } else if (routePath is TopicRoutePath) {
      return RouteInformation(location: '/topic/${routePath.topicId}');
    } else if (routePath is AppRoutePath) {
      switch (routePath.appPage) {
        case AppPage.login:
          return const RouteInformation(location: '/login');
        case AppPage.consumables:
          return const RouteInformation(location: '/consumables');
        case AppPage.recycle_bin:
          return const RouteInformation(location: '/recyclebin');
      }
    }
    return const RouteInformation(location: '/');
  }
}

/// 将 URL 转换成 RoutePath
RoutePath parseUrl(String location) {
  final uri = Uri.parse(location);
  if (uri.pathSegments.length == 1) {
    if (uri.pathSegments[0] == 'iot') return HomeRoutePath(appTab: AppTab.iot);
    if (uri.pathSegments[0] == 'board')
      return HomeRoutePath(appTab: AppTab.board);
    if (uri.pathSegments[0] == 'storage')
      return HomeRoutePath(appTab: AppTab.storage);
    if (uri.pathSegments[0] == 'board')
      return HomeRoutePath(appTab: AppTab.board);
    if (uri.pathSegments[0] == 'consumables')
      return AppRoutePath(AppPage.consumables);
    if (uri.pathSegments[0] == 'login') return AppRoutePath(AppPage.login);
    if (uri.pathSegments[0] == 'recyclebin')
      return AppRoutePath(AppPage.recycle_bin);
  }
  if (uri.pathSegments.length == 2) {
    switch (uri.pathSegments[0]) {
      case 'item':
        return ItemRoutePath(itemName: uri.pathSegments[1]);
      case 'topic':
        return TopicRoutePath(topicId: uri.pathSegments[1]);
      case 'storage':
        return StorageRoutePath(storageName: uri.pathSegments[1]);
    }
  }
  return HomeRoutePath(appTab: null);
}
