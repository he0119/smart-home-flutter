/// IOT，存储管理，博客，留言板
enum AppTab { iot, storage, blog, board }

extension AppTabExtension on AppTab {
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
}
