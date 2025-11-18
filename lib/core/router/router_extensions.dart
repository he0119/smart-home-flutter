import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smarthome/core/core.dart';

import 'app_router.dart';

// GoRouter扩展
extension GoRouterExtension on BuildContext {
  // 基础导航方法
  void goHome() {
    final container = ProviderScope.containerOf(this, listen: false);
    final defaultTab = container.read(settingsProvider).defaultPage;
    goTab(defaultTab);
  }

  void goLogin() => go(AppRoutes.login);

  void goStorage() => go(AppRoutes.storage);

  void goBlog() => go(AppRoutes.blog);

  void goBoard() => go(AppRoutes.board);

  void goSettings() => push(AppRoutes.settings);

  void goBlogSettings() => push(AppRoutes.blogSettings);

  void goConsumables() => push(AppRoutes.consumables);

  void goRecycleBin() => push(AppRoutes.recycleBin);

  void goSearch() => push(AppRoutes.search);

  void goAdmin() => push(AppRoutes.admin);

  // 带参数的导航
  void goStorageDetail(String storageId) =>
      push(AppRoutes.storageDetailPath(storageId));

  void goItemDetail(String itemId) => push(AppRoutes.itemDetailPath(itemId));

  void goTopicDetail(String topicId) =>
      push(AppRoutes.topicDetailPath(topicId));

  void goPictureDetail(String pictureId) =>
      push(AppRoutes.pictureDetailPath(pictureId));

  // 替换当前路由
  void replaceStorageRootDetail() => replace(AppRoutes.storageRootDetail);

  // 根据AppTab导航
  void goTab(AppTab tab) {
    switch (tab) {
      case AppTab.storage:
        goStorage();
        break;
      case AppTab.blog:
        goBlog();
        break;
      case AppTab.board:
        goBoard();
        break;
    }
  }

  // 根据AppPage导航
  void goAppPage(AppPage page) {
    switch (page) {
      case AppPage.login:
        goLogin();
        break;
      case AppPage.consumables:
        goConsumables();
        break;
      case AppPage.recycleBin:
        goRecycleBin();
        break;
    }
  }

  // 返回上一页
  void goBack() {
    if (canPop()) {
      pop();
    } else {
      goHome();
    }
  }

  // 带结果返回
  void goBackWithResult<T>(T result) {
    if (canPop()) {
      pop(result);
    } else {
      goHome();
    }
  }
}
