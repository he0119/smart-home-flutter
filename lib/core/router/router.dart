import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smarthome/blog/blog.dart';
import 'package:smarthome/board/board.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/storage/storage.dart';

import 'app_router.dart';

// GoRouter 刷新监听器
class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(SettingsState settings) {
    _settings = settings;
  }

  late SettingsState _settings;

  void update(SettingsState settings) {
    if (_settings.isLogin != settings.isLogin) {
      _settings = settings;
      notifyListeners();
    }
  }
}

// 路由提供者
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _GoRouterRefreshStream(ref.read(settingsProvider));

  // 监听 settings 变化并更新 notifier
  ref.listen(settingsProvider, (previous, next) {
    notifier.update(next);
  });

  return GoRouter(
    restorationScopeId: 'router',
    initialLocation: ref.read(settingsProvider).defaultPage.route,
    refreshListenable: notifier,
    redirect: (context, state) {
      // 每次重定向时都读取最新的 settings 状态
      final settings = ref.read(settingsProvider);
      final isLogin = settings.isLogin;

      // 登录状态检查
      if (!isLogin && state.matchedLocation != AppRoutes.login) {
        return AppRoutes.login;
      }
      if (isLogin &&
          (state.matchedLocation == AppRoutes.login ||
              state.matchedLocation == AppRoutes.home)) {
        // 检查是否有 next 参数
        final next = state.uri.queryParameters['next'];
        if (next != null && next.isNotEmpty) {
          return next;
        }
        return ref.read(settingsProvider).defaultPage.route;
      }
      return null;
    },
    routes: [
      // 登录页面
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),

      // 存储管理路由
      GoRoute(
        path: AppRoutes.storage,
        pageBuilder: (context, state) => buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const StorageHomePage(),
        ),
      ),

      // 博客路由
      GoRoute(
        path: AppRoutes.blog,
        pageBuilder: (context, state) => buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const BlogHomePage(),
        ),
      ),

      // 留言板路由
      GoRoute(
        path: AppRoutes.board,
        pageBuilder: (context, state) => buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const BoardHomePage(),
        ),
      ),

      // 话题详情
      GoRoute(
        path: AppRoutes.topicDetail,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return TopicDetailPage(topicId: id);
        },
      ),

      // 物品详情
      GoRoute(
        path: AppRoutes.itemDetail,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return ItemDetailPage(itemId: id);
        },
      ),

      // 位置详情
      GoRoute(
        path: AppRoutes.storageDetail,
        builder: (context, state) {
          final idParam = state.pathParameters['id'] ?? '';
          final id = idParam == AppRoutes.storageRootId ? '' : idParam;
          return StorageDetailPage(storageId: id);
        },
      ),

      // 图片详情
      GoRoute(
        path: AppRoutes.pictureDetail,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return PicturePage(pictureId: id);
        },
      ),

      // 耗材页面
      GoRoute(
        path: AppRoutes.consumables,
        builder: (context, state) => const ConsumablesPage(),
      ),

      // 回收站
      GoRoute(
        path: AppRoutes.recycleBin,
        builder: (context, state) => const RecycleBinPage(),
      ),

      // 设置页面
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsPage(),
      ),

      // 博客设置
      GoRoute(
        path: AppRoutes.blogSettings,
        builder: (context, state) => const BlogSettingsPage(),
      ),

      // 主题设置
      GoRoute(
        path: AppRoutes.themeSettings,
        builder: (context, state) => const ThemeModePage(),
      ),

      // API 网址设置
      GoRoute(
        path: AppRoutes.apiUrlSettings,
        builder: (context, state) => const ApiUrlPage(),
      ),

      // 管理网址设置
      GoRoute(
        path: AppRoutes.adminUrlSettings,
        builder: (context, state) => const AdminUrlPage(),
      ),

      // 默认主页设置
      GoRoute(
        path: AppRoutes.defaultPageSettings,
        builder: (context, state) => const DefaultPage(),
      ),

      // 会话管理
      GoRoute(
        path: AppRoutes.sessionSettings,
        builder: (context, state) => const SessionPage(),
      ),

      // 小米推送设置
      GoRoute(
        path: AppRoutes.miPushSettings,
        builder: (context, state) => const MiPushPage(),
      ),

      // 博客网址设置
      GoRoute(
        path: AppRoutes.blogUrlSettings,
        builder: (context, state) => const BlogUrlPage(),
      ),

      // 博客管理网址设置
      GoRoute(
        path: AppRoutes.blogAdminUrlSettings,
        builder: (context, state) => const BlogAdminUrlPage(),
      ),

      // 评论排序设置
      GoRoute(
        path: AppRoutes.commentOrderSettings,
        builder: (context, state) => const CommentOrderPage(),
      ),

      // 搜索页面
      GoRoute(
        path: AppRoutes.search,
        builder: (context, state) => const SearchPage(),
      ),

      // 管理页面
      GoRoute(
        path: AppRoutes.admin,
        builder: (context, state) => const AdminPage(),
      ),

      // 物品编辑页面
      GoRoute(
        path: AppRoutes.itemEdit,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return ItemEditPage(
            isEditing: true,
            item: Item(id: id, name: ''),
          );
        },
      ),

      // 添加物品图片页面
      GoRoute(
        path: AppRoutes.itemPictureAdd,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return PictureAddPage(itemId: id);
        },
      ),
    ],
  );
});
