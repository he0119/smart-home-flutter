import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smart_home/blocs/board/blocs.dart';
import 'package:smart_home/models/app_tab.dart';
import 'package:smart_home/pages/board/topic_edit_page.dart';
import 'package:smart_home/pages/board/widgets/topic_list.dart';
import 'package:smart_home/pages/error_page.dart';
import 'package:smart_home/pages/loading_page.dart';
import 'package:smart_home/repositories/board_repository.dart';
import 'package:smart_home/widgets/home_page.dart';

class BoardHomePage extends StatelessWidget {
  const BoardHomePage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyHomePage(
      activeTab: AppTab.board,
      body: _BoardHomeBody(),
      floatingActionButton: FloatingActionButton(
        tooltip: '添加话题',
        child: Icon(Icons.create),
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => TopicEditBloc(
                    boardRepository:
                        RepositoryProvider.of<BoardRepository>(context)),
                child: TopicEditPage(
                  isEditing: false,
                ),
              ),
            ),
          );
          BlocProvider.of<BoardHomeBloc>(context).add(BoardHomeRefreshed());
        },
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
        if (state is BoardHomeFailure) {
          return ErrorPage(
            onPressed: () {
              BlocProvider.of<BoardHomeBloc>(context).add(BoardHomeRefreshed());
            },
            message: state.message,
          );
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
        return LoadingPage();
      },
    );
  }
}
