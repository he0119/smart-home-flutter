import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smarthome/blog/blog.dart';
import 'package:smarthome/board/board.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/core/view/admin_page.dart';
import 'package:smarthome/storage/storage.dart';
import 'package:smarthome/storage/view/item_edit_page.dart';
import 'package:smarthome/storage/view/picture_add_page.dart';

import 'app_router.dart';

// 路由提供者
final routerProvider = Provider<GoRouter>((ref) {
  final settings = ref.watch(settingsProvider);
  final isLogin = settings.isLogin;

  return GoRouter(
    initialLocation: settings.defaultPage.route,
    redirect: (context, state) {
      // 登录状态检查
      if (!isLogin && state.matchedLocation != AppRoutes.login) {
        return AppRoutes.login;
      }
      if (isLogin &&
          (state.matchedLocation == AppRoutes.login ||
              state.matchedLocation == AppRoutes.home)) {
        return settings.defaultPage.route;
      }
      return null;
    },
    routes: [
      // 登录页面
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) => buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const LoginScreen(),
        ),
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
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: TopicDetailPage(topicId: id),
          );
        },
      ),

      // 物品详情
      GoRoute(
        path: AppRoutes.itemDetail,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: ItemDetailPage(itemId: id),
          );
        },
      ),

      // 位置详情
      GoRoute(
        path: AppRoutes.storageDetail,
        pageBuilder: (context, state) {
          final idParam = state.pathParameters['id'] ?? '';
          final id = idParam == AppRoutes.storageRootId ? '' : idParam;
          return buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: StorageDetailPage(storageId: id),
          );
        },
      ),

      // 图片详情
      GoRoute(
        path: AppRoutes.pictureDetail,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: PicturePage(pictureId: id),
          );
        },
      ),

      // 耗材页面
      GoRoute(
        path: AppRoutes.consumables,
        pageBuilder: (context, state) => buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const ConsumablesPage(),
        ),
      ),

      // 回收站
      GoRoute(
        path: AppRoutes.recycleBin,
        pageBuilder: (context, state) => buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const RecycleBinPage(),
        ),
      ),

      // 设置页面
      GoRoute(
        path: AppRoutes.settings,
        pageBuilder: (context, state) => buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const SettingsPage(),
        ),
      ),

      // 博客设置
      GoRoute(
        path: AppRoutes.blogSettings,
        pageBuilder: (context, state) => buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const BlogSettingsPage(),
        ),
      ),

      // 搜索页面
      GoRoute(
        path: AppRoutes.search,
        pageBuilder: (context, state) => buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const SearchPage(),
        ),
      ),

      // 管理页面
      GoRoute(
        path: AppRoutes.admin,
        pageBuilder: (context, state) => buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const AdminPage(),
        ),
      ),

      // 物品编辑页面
      GoRoute(
        path: AppRoutes.itemEdit,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: ItemEditPage(
              isEditing: true,
              item: Item(id: id, name: ''),
            ),
          );
        },
      ),

      // 添加物品图片页面
      GoRoute(
        path: AppRoutes.itemPictureAdd,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: PictureAddPage(itemId: id),
          );
        },
      ),
    ],
  );
});
