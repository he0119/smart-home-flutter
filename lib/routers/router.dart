import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smarthome/app/settings/settings_controller.dart';
import 'package:smarthome/blog/blog.dart';
import 'package:smarthome/board/board.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/iot/bloc/blocs.dart';
import 'package:smarthome/iot/iot.dart';
import 'package:smarthome/storage/storage.dart';
import 'package:smarthome/widgets/tab_selector.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _homeNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'home');
// 为了保存路由状态
final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _homeNavigatorKey,
      builder: (context, state, child) {
        return Scaffold(
          body: child,
          bottomNavigationBar: const TabSelector(),
        );
      },
      routes: [
        GoRoute(
          path: '/storage',
          builder: (context, state) {
            BlocProvider.of<StorageHomeBloc>(context)
                .add(const StorageHomeFetched(itemType: ItemType.all));
            return const StorageHomeScreen();
          },
        ),
        GoRoute(
          path: '/iot',
          builder: (context, state) {
            BlocProvider.of<StorageHomeBloc>(context)
                .add(const StorageHomeFetched(itemType: ItemType.all));
            return MultiBlocProvider(
              providers: [
                BlocProvider<DeviceDataBloc>(
                  // 因为只有一个设备就先写死
                  create: (context) => DeviceDataBloc(
                    iotRepository:
                        RepositoryProvider.of<IotRepository>(context),
                    deviceId: 'RGV2aWNlOjE=',
                    client: RepositoryProvider.of<GraphQLApiClient>(context),
                  )..add(const DeviceDataStarted()),
                ),
                BlocProvider<DeviceEditBloc>(
                  create: (context) => DeviceEditBloc(
                    iotRepository:
                        RepositoryProvider.of<IotRepository>(context),
                  ),
                ),
              ],
              child: const IotHomeScreen(),
            );
          },
        ),
        GoRoute(
          path: '/blog',
          builder: (context, state) {
            BlocProvider.of<StorageHomeBloc>(context)
                .add(const StorageHomeFetched(itemType: ItemType.all));
            return const BlogHomeScreen();
          },
        ),
        GoRoute(
          path: '/board',
          builder: (context, state) {
            BlocProvider.of<StorageHomeBloc>(context)
                .add(const StorageHomeFetched(itemType: ItemType.all));
            return const BoardHomeScreen();
          },
        ),
      ],
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
  ],
  redirect: (BuildContext context, GoRouterState state) {
    final settingsController = context.read<SettingsController>();
    if (!settingsController.isLogin) {
      if (state.matchedLocation == '/login') {
        return null;
      }
      return '/login?redirect=${state.uri.toString()}';
    } else {
      if (state.uri.toString() == '/') {
        return settingsController.defaultPage.path;
      }
      if (state.matchedLocation == '/login') {
        if (state.uri.queryParameters['redirect'] != null) {
          return state.uri.queryParameters['redirect'];
        } else {
          // 如果是登录状态，但是访问的是登录页面，那么就跳转到默认页面
          return settingsController.defaultPage.path;
        }
      }
      return null;
    }
  },
);
