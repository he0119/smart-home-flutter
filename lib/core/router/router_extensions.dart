import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smarthome/core/core.dart';

import 'app_router.dart';

// GoRouter扩展
extension GoRouterExtension on BuildContext {
  // 基础导航方法
  void goHome() => go(AppRoutes.storage);

  void goLogin() => go(AppRoutes.login);

  void goStorage() => go(AppRoutes.storage);

  void goBlog() => go(AppRoutes.blog);

  void goBoard() => go(AppRoutes.board);

  void goSettings() => go(AppRoutes.settings);

  void goBlogSettings() => go(AppRoutes.blogSettings);

  void goConsumables() => go(AppRoutes.consumables);

  void goRecycleBin() => go(AppRoutes.recycleBin);

  // 带参数的导航
  void goStorageDetail(String storageId) => go('/storage/$storageId');

  void goItemDetail(String itemId) => go('/item/$itemId');

  void goTopicDetail(String topicId) => go('/board/topic/$topicId');

  void goPictureDetail(String pictureId) => go('/picture/$pictureId');

  // 替换当前路由
  void replaceHome() => replace(AppRoutes.storage);

  void replaceLogin() => replace(AppRoutes.login);

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

  // 搜索页面
  void goSearch() => push('/search');

  // 管理页面
  void goAdmin() => push('/admin');

  // 存储页面导航 - 重置到根存储页面
  void setStoragePage() {
    go('/storage');
  }

  // 存储页面导航 - 导航到指定存储页面
  void setStoragePageWithStorage(String storageId) {
    go('/storage/$storageId');
  }
}
