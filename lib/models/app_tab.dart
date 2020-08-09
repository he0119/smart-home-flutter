/// IOT，存储管理，博客，留言板
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
      default:
        return '留言';
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
      default:
        return '留言板';
    }
  }
}
