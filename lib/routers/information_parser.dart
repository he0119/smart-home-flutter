import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'package:smart_home/models/app_tab.dart';
import 'package:smart_home/repositories/repositories.dart';
import 'package:smart_home/routers/route_path.dart';

class MyRouteInformationParser extends RouteInformationParser<RoutePath> {
  static final Logger _log = Logger('InformationParser');
  final StorageRepository storageRepository;

  MyRouteInformationParser({
    this.storageRepository,
  });

  @override
  Future<RoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    _log.fine('parseRouteInformation: ${routeInformation.location}');
    final uri = Uri.parse(routeInformation.location);
    _log.fine('uri pathSegments: ${uri.pathSegments}');
    if (uri.pathSegments.length == 1) {
      if (uri.pathSegments[0] == 'iot') return AppRoutePath(appTab: AppTab.iot);
      if (uri.pathSegments[0] == 'board')
        return AppRoutePath(appTab: AppTab.board);
      if (uri.pathSegments[0] == 'storage')
        return AppRoutePath(appTab: AppTab.storage);
      if (uri.pathSegments[0] == 'board')
        return AppRoutePath(appTab: AppTab.board);
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
    return AppRoutePath(appTab: null);
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
    if (routePath is StorageRoutePath) {
      if (routePath.storageName == 'home') {
        return RouteInformation(location: '/storage/home');
      }
      return RouteInformation(location: '/storage/${routePath.storageName}');
    }
    if (routePath is ItemRoutePath)
      return RouteInformation(location: '/item/${routePath.itemName}');
    if (routePath is TopicRoutePath)
      return RouteInformation(location: '/topic/${routePath.topicId}');
    return const RouteInformation(location: '/');
  }
}
