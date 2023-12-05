import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smarthome/app/settings/settings_controller.dart';
import 'package:smarthome/blog/blog.dart';
import 'package:smarthome/board/board.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/iot/bloc/blocs.dart';
import 'package:smarthome/iot/iot.dart';
import 'package:smarthome/storage/storage.dart';

// 为了保存路由状态
final GoRouter router = GoRouter(
  initialLocation: '/',
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
                iotRepository: RepositoryProvider.of<IotRepository>(context),
                deviceId: 'RGV2aWNlOjE=',
              )..add(const DeviceDataStarted()),
            ),
            BlocProvider<DeviceEditBloc>(
              create: (context) => DeviceEditBloc(
                iotRepository: RepositoryProvider.of<IotRepository>(context),
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
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
  ],
  redirect: (BuildContext context, GoRouterState state) {
    // https://github.com/flutter/flutter/issues/127313
    final settingsController =
        Provider.of<SettingsController>(context, listen: false);
    if (!settingsController.isLogin) {
      if (state.matchedLocation == '/login') {
        return null;
      }
      return '/login?redirect=${state.uri.toString()}';
    }

    if (state.matchedLocation == '/') {
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
  },
);
