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

// 路由工具类
class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  // 获取当前上下文
  static BuildContext? get currentContext => navigatorKey.currentContext;
  
  // 全局导航方法
  static void goHome() => currentContext?.goHome();
  
  static void goLogin() => currentContext?.goLogin();
  
  static void goStorage() => currentContext?.goStorage();
  
  static void goBlog() => currentContext?.goBlog();
  
  static void goBoard() => currentContext?.goBoard();
  
  static void goSettings() => currentContext?.goSettings();
  
  static void goBlogSettings() => currentContext?.goBlogSettings();
  
  static void goConsumables() => currentContext?.goConsumables();
  
  static void goRecycleBin() => currentContext?.goRecycleBin();
  
  static void goStorageDetail(String storageId) => 
      currentContext?.goStorageDetail(storageId);
  
  static void goItemDetail(String itemId) => 
      currentContext?.goItemDetail(itemId);
  
  static void goTopicDetail(String topicId) => 
      currentContext?.goTopicDetail(topicId);
  
  static void goPictureDetail(String pictureId) => 
      currentContext?.goPictureDetail(pictureId);
  
  static void goTab(AppTab tab) => currentContext?.goTab(tab);
  
  static void goAppPage(AppPage page) => currentContext?.goAppPage(page);
  
  static void goBack() => currentContext?.goBack();
  
  static void goBackWithResult<T>(T result) => 
      currentContext?.goBackWithResult(result);
}