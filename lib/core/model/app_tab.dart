import 'package:flutter/material.dart';
import 'package:smarthome/blog/blog.dart';
import 'package:smarthome/board/board.dart';
import 'package:smarthome/iot/iot.dart';
import 'package:smarthome/storage/storage.dart';

/// IOT, 存储管理, 博客, 留言板
enum AppTab { iot, storage, blog, board }

extension AppTabExtension on AppTab {
  /// 底部导航栏显示的名称
  String get name {
    switch (this) {
      case AppTab.iot:
        return 'IOT';
      case AppTab.storage:
        return '物品';
      case AppTab.blog:
        return '博客';
      case AppTab.board:
        return '留言板';
    }
  }

  /// 底部导航栏显示的图标
  Icon get icon {
    switch (this) {
      case AppTab.iot:
        return Icon(Icons.cloud);
      case AppTab.storage:
        return Icon(Icons.storage);
      case AppTab.blog:
        return Icon(Icons.web);
      case AppTab.board:
        return Icon(Icons.chat);
    }
  }

  /// 应用栏上显示的名称
  String get title {
    switch (this) {
      case AppTab.iot:
        return '物联网';
      case AppTab.storage:
        return '物品管理';
      case AppTab.blog:
        return '博客';
      case AppTab.board:
        return '留言板';
    }
  }

  /// 对应的页面
  Page get page {
    switch (this) {
      case AppTab.iot:
        return IotHomePage();
      case AppTab.storage:
        return StorageHomePage();
      case AppTab.blog:
        return BlogHomePage();
      case AppTab.board:
        return BoardHomePage();
    }
  }
}

/// 登录, 物品耗材, 回收站
enum AppPage { login, consumables, recycleBin }

/// 主页, 物联网, 博客
enum AppSettings { home, iot, blog }
