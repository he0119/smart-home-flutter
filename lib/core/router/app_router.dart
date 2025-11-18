import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// 路由路径常量
class AppRoutes {
  static const String login = '/login';
  static const String home = '/';
  static const String storage = '/storage';
  static const String storageDetail = '/storage/:id';
  static const String itemDetail = '/item/:id';
  static const String topicDetail = '/topic/:id';
  static const String pictureDetail = '/picture/:id';
  static const String consumables = '/consumables';
  static const String recycleBin = '/recyclebin';
  static const String settings = '/settings';
  static const String blogSettings = '/settings/blog';
  
  // 设置子页面
  static const String themeSettings = '/settings/theme';
  static const String apiUrlSettings = '/settings/api-url';
  static const String adminUrlSettings = '/settings/admin-url';
  static const String defaultPageSettings = '/settings/default-page';
  static const String sessionSettings = '/settings/sessions';
  static const String miPushSettings = '/settings/mipush';
  static const String blogUrlSettings = '/settings/blog-url';
  static const String blogAdminUrlSettings = '/settings/blog-admin-url';
  static const String commentOrderSettings = '/settings/comment-order';
  
  static const String blog = '/blog';
  static const String board = '/board';
  static const String search = '/search';
  static const String admin = '/admin';
  static const String itemEdit = '/item/:id/edit';
  static const String itemPictureAdd = '/item/:id/picture/add';

  // Special token for the virtual root storage detail page
  static const String storageRootId = 'root';
  static const String storageRootDetail = '$storage/$storageRootId';

  // Build a concrete storage detail path, mapping the root id when needed
  static String storageDetailPath(String storageId) {
    return storageId.isEmpty ? storageRootDetail : '$storage/$storageId';
  }

  static String itemDetailPath(String itemId) => '/item/$itemId';

  static String topicDetailPath(String topicId) => '/topic/$topicId';

  static String pictureDetailPath(String pictureId) => '/picture/$pictureId';
}

// 自定义路由转换
CustomTransitionPage<T> buildPageWithDefaultTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}
