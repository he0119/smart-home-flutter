import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/blocs/board/blocs.dart';
import 'package:smart_home/models/app_tab.dart';
import 'package:smart_home/pages/board/widgets/topic_list.dart';
import 'package:smart_home/repositories/board_repository.dart';
import 'package:smart_home/repositories/graphql_api_client.dart';
import 'package:smart_home/widgets/gravatar.dart';
import 'package:smart_home/widgets/tab_selector.dart';

class BoardHomePage extends StatelessWidget {
  const BoardHomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => BoardRepository(
        graphqlApiClient: RepositoryProvider.of<GraphQLApiClient>(context),
      ),
      child: BlocProvider(
        create: (context) => BoardHomeBloc(
          boardRepository: RepositoryProvider.of<BoardRepository>(context),
        )..add(BoardHomeStarted()),
        child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) => Scaffold(
            appBar: AppBar(
              leading: state is Authenticated
                  ? IconButton(
                      icon: CircleGravatar(email: state.currentUser.email),
                      onPressed: null,
                    )
                  : null,
              title: Text('留言板'),
            ),
            body: _BoardHomeBody(),
            bottomNavigationBar: TabSelector(
              activeTab: AppTab.board,
              onTabSelected: (tab) =>
                  BlocProvider.of<TabBloc>(context).add(UpdateTab(tab)),
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () async {
                // TODO: 添加页面转跳逻辑
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _BoardHomeBody extends StatelessWidget {
  const _BoardHomeBody({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BoardHomeBloc, BoardHomeState>(
      builder: (context, state) {
        if (state is BoardHomeInProgress) {
          return Center(child: CircularProgressIndicator());
        }
        if (state is BoardHomeError) {
          return Center(child: Text(state.message));
        }
        if (state is BoardHomeSuccess) {
          // 从各种类型详情页返回
          return RefreshIndicator(
            onRefresh: () async {
              BlocProvider.of<BoardHomeBloc>(context).add(BoardHomeRefreshed());
            },
            child: TopicList(topics: state.topics),
          );
        }
        return Container();
      },
    );
  }
}
