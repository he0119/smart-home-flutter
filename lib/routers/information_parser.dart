import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/routers/route_path.dart';

class MyRouteInformationParser extends RouteInformationParser<RoutePath> {
  static final Logger _log = Logger('InformationParser');

  @override
  Future<RoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    _log.fine('parseRouteInformation: ${routeInformation.location}');
    return parseUrl(routeInformation.location!);
  }

  @override
  RouteInformation restoreRouteInformation(RoutePath configuration) {
    _log.fine('restoreRouteInformation: $configuration');
    if (configuration is HomeRoutePath) {
      switch (configuration.appTab) {
        case AppTab.blog:
          return const RouteInformation(location: '/blog');
        case AppTab.iot:
          return const RouteInformation(location: '/iot');
        case AppTab.storage:
          return const RouteInformation(location: '/storage');
        case AppTab.board:
          return const RouteInformation(location: '/board');
        default:
      }
    } else if (configuration is StorageRoutePath) {
      return RouteInformation(location: '/storage/${configuration.storageName}');
    } else if (configuration is ItemRoutePath) {
      return RouteInformation(location: '/item/${configuration.itemName}');
    } else if (configuration is TopicRoutePath) {
      return RouteInformation(location: '/topic/${configuration.topicId}');
    } else if (configuration is AppRoutePath) {
      switch (configuration.appPage) {
        case AppPage.login:
          return const RouteInformation(location: '/login');
        case AppPage.consumables:
          return const RouteInformation(location: '/consumables');
        case AppPage.recycleBin:
          return const RouteInformation(location: '/recyclebin');
      }
    } else if (configuration is SettingsRoutePath) {
      switch (configuration.appSettings) {
        case AppSettings.home:
          return const RouteInformation(location: '/settings');
        case AppSettings.iot:
          return const RouteInformation(location: '/settings/iot');
        case AppSettings.blog:
          return const RouteInformation(location: '/settings/blog');
        default:
      }
    } else if (configuration is PictureRoutePath) {
      return RouteInformation(location: '/picture/${configuration.pictureId}');
    }
    return const RouteInformation(location: '/');
  }
}

/// 将 URL 转换成 RoutePath
RoutePath parseUrl(String location) {
  final uri = Uri.parse(location);
  if (uri.pathSegments.length == 1) {
    if (uri.pathSegments[0] == 'iot') return HomeRoutePath(appTab: AppTab.iot);
    if (uri.pathSegments[0] == 'board') {
      return HomeRoutePath(appTab: AppTab.board);
    }
    if (uri.pathSegments[0] == 'storage') {
      return HomeRoutePath(appTab: AppTab.storage);
    }
    if (uri.pathSegments[0] == 'blog') {
      return HomeRoutePath(appTab: AppTab.blog);
    }
    if (uri.pathSegments[0] == 'consumables') {
      return AppRoutePath(AppPage.consumables);
    }
    if (uri.pathSegments[0] == 'login') return AppRoutePath(AppPage.login);
    if (uri.pathSegments[0] == 'recyclebin') {
      return AppRoutePath(AppPage.recycleBin);
    }
    if (uri.pathSegments[0] == 'settings') {
      return SettingsRoutePath(appSettings: AppSettings.home);
    }
  }
  if (uri.pathSegments.length == 2) {
    switch (uri.pathSegments[0]) {
      case 'item':
        return ItemRoutePath(itemName: uri.pathSegments[1]);
      case 'topic':
        return TopicRoutePath(topicId: uri.pathSegments[1]);
      case 'storage':
        return StorageRoutePath(storageName: uri.pathSegments[1]);
      case 'settings':
        // 单独的设置界面
        switch (uri.pathSegments[1]) {
          case 'iot':
            return SettingsRoutePath(appSettings: AppSettings.iot);
          case 'blog':
            return SettingsRoutePath(appSettings: AppSettings.blog);
        }
        break;
      case 'picture':
        return PictureRoutePath(pictureId: uri.pathSegments[1]);
    }
  }
  return HomeRoutePath(appTab: null);
}
