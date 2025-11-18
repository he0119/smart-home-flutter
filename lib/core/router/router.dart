import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/blog/blog.dart';
import 'package:smarthome/board/board.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/core/view/admin_page.dart';
import 'package:smarthome/storage/storage.dart';
import 'app_router.dart';
import 'package:smarthome/storage/view/item_edit_page.dart';
import 'package:smarthome/storage/view/picture_add_page.dart';

// 路由提供者
final routerProvider = Provider<GoRouter>((ref) {
  final settings = ref.watch(settingsProvider);
  final isLogin = settings.isLogin;

  return GoRouter(
    initialLocation: settings.defaultPage == AppTab.storage
        ? AppRoutes.storage
        : settings.defaultPage == AppTab.blog
            ? AppRoutes.blog
            : AppRoutes.board,
    redirect: (context, state) {
      // 登录状态检查
      if (!isLogin && state.matchedLocation != AppRoutes.login) {
        return AppRoutes.login;
      }
      if (isLogin && state.matchedLocation == AppRoutes.login) {
        return AppRoutes.storage;
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
      
      // 主页面Shell路由
      ShellRoute(
        builder: (context, state, child) {
          return HomeShell(
            location: state.matchedLocation,
            child: child,
          );
        },
        routes: [
          // 存储管理路由
          GoRoute(
            path: AppRoutes.storage,
            pageBuilder: (context, state) => buildPageWithDefaultTransition(
              context: context,
              state: state,
              child: const StorageHomePage(),
            ),
            routes: [
              // 存储详情
              GoRoute(
                path: ':id',
                pageBuilder: (context, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return buildPageWithDefaultTransition(
                    context: context,
                    state: state,
                    child: StorageDetailPage(storageId: id),
                  );
                },
              ),
            ],
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
            routes: [
              // 话题详情
              GoRoute(
                path: 'topic/:id',
                pageBuilder: (context, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return buildPageWithDefaultTransition(
                    context: context,
                    state: state,
                    child: TopicDetailPage(topicId: id),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      
      // 独立页面路由
      
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
        path: '/search',
        pageBuilder: (context, state) => buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const SearchPage(),
        ),
      ),
      
      // 管理页面
      GoRoute(
        path: '/admin',
        pageBuilder: (context, state) => buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const AdminPage(),
        ),
      ),
      
      // 物品编辑页面
      GoRoute(
        path: '/item/:id/edit',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: ItemEditPage(isEditing: true, item: Item(id: id, name: '')),
          );
        },
      ),
      
      // 添加物品图片页面
      GoRoute(
        path: '/item/:id/picture/add',
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