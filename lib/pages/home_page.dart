import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/blocs/board/blocs.dart';
import 'package:smart_home/blocs/storage/blocs.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/pages/blog/home_page.dart';
import 'package:smart_home/pages/board/home_page.dart';
import 'package:smart_home/pages/iot/home_page.dart';
import 'package:smart_home/pages/login_page.dart';
import 'package:smart_home/pages/storage/home_page.dart';
import 'package:smart_home/repositories/board_repository.dart';
import 'package:smart_home/repositories/graphql_api_client.dart';
import 'package:smart_home/repositories/storage_repository.dart';
import 'package:smart_home/repositories/user_repository.dart';
import 'package:smart_home/repositories/version_repository.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthenticationBloc(
        userRepository: RepositoryProvider.of<UserRepository>(context),
        graphqlApiClient: RepositoryProvider.of<GraphQLApiClient>(context),
      )..add(AuthenticationStarted()),
      child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state is Authenticated || state is AuthenticationUninitialized) {
            return MultiBlocProvider(
              providers: [
                BlocProvider<TabBloc>(
                  create: (context) => TabBloc(),
                ),
                BlocProvider<SnackBarBloc>(
                  create: (context) => SnackBarBloc(),
                ),
                BlocProvider<UpdateBloc>(
                  create: (context) => UpdateBloc(
                    versionRepository:
                        RepositoryProvider.of<VersionRepository>(context),
                  ),
                ),
              ],
              child: _HomePage(),
            );
          }
          return LoginPage();
        },
      ),
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 仅在客户端上注册 Shortcut
    if (!kIsWeb) {
      final QuickActions quickActions = QuickActions();
      quickActions.initialize((String shortcutType) async {
        if (shortcutType == 'action_iot') {
          BlocProvider.of<TabBloc>(context).add(UpdateTab(AppTab.iot));
        } else {
          BlocProvider.of<TabBloc>(context).add(UpdateTab(AppTab.blog));
        }
      });
      quickActions.setShortcutItems(
        <ShortcutItem>[
          // TODO: 给快捷方式添加图标
          const ShortcutItem(type: 'action_iot', localizedTitle: 'IOT'),
          const ShortcutItem(type: 'action_blog', localizedTitle: '博客'),
        ],
      );
    }
    return BlocBuilder<TabBloc, AppTab>(
      builder: (context, activeTab) {
        if (activeTab == AppTab.storage) {
          return RepositoryProvider(
            create: (context) => StorageRepository(
              graphqlApiClient:
                  RepositoryProvider.of<GraphQLApiClient>(context),
            ),
            child: BlocProvider<StorageHomeBloc>(
              create: (context) => StorageHomeBloc(
                storageRepository:
                    RepositoryProvider.of<StorageRepository>(context),
              )..add(StorageHomeStarted()),
              child: Navigator(onGenerateRoute: (_) => StorageHomePage.route()),
            ),
          );
        }
        if (activeTab == AppTab.blog) {
          return BlogHomePage();
        }
        if (activeTab == AppTab.iot) {
          return IotHomePage();
        }
        return RepositoryProvider(
          create: (context) => BoardRepository(
            graphqlApiClient: RepositoryProvider.of<GraphQLApiClient>(context),
          ),
          child: BlocProvider<BoardHomeBloc>(
            create: (context) => BoardHomeBloc(
              boardRepository: RepositoryProvider.of<BoardRepository>(context),
            )..add(BoardHomeStarted()),
            child: Navigator(onGenerateRoute: (_) => BoardHomePage.route()),
          ),
        );
      },
    );
  }
}
