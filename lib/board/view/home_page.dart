import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smarthome/board/bloc/blocs.dart';
import 'package:smarthome/board/view/topic_edit_page.dart';
import 'package:smarthome/board/view/widgets/topic_item.dart';
import 'package:smarthome/board/repository/board_repository.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/widgets/center_loading_indicator.dart';
import 'package:smarthome/widgets/error_message_button.dart';
import 'package:smarthome/widgets/home_page.dart';
import 'package:smarthome/widgets/infinite_list.dart';

class BoardHomePage extends Page {
  BoardHomePage()
      : super(
          key: ValueKey('board'),
          name: '/board',
        );

  @override
  Route createRoute(BuildContext context) {
    BlocProvider.of<BoardHomeBloc>(context).add(BoardHomeFetched());
    return MaterialPageRoute(
      settings: this,
      builder: (context) => BoardHomeScreen(),
    );
  }
}

class BoardHomeScreen extends StatelessWidget {
  const BoardHomeScreen({
    Key? key,
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
          BlocProvider.of<BoardHomeBloc>(context)
              .add(BoardHomeFetched(cache: false));
        },
      ),
    );
  }
}

class _BoardHomeBody extends StatelessWidget {
  const _BoardHomeBody({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BoardHomeBloc, BoardHomeState>(
      builder: (context, state) {
        if (state is BoardHomeFailure) {
          return ErrorMessageButton(
            onPressed: () {
              BlocProvider.of<BoardHomeBloc>(context)
                  .add(BoardHomeFetched(cache: false));
            },
            message: state.message,
          );
        }
        if (state is BoardHomeSuccess) {
          // 从各种类型详情页返回
          return RefreshIndicator(
            onRefresh: () async {
              BlocProvider.of<BoardHomeBloc>(context)
                  .add(BoardHomeFetched(cache: false));
            },
            child: InfiniteList(
              items: state.topics,
              hasReachedMax: state.hasReachedMax,
              itemBuilder: (context, dynamic item) => TopicItem(topic: item),
              onFetch: () {
                BlocProvider.of<BoardHomeBloc>(context).add(BoardHomeFetched());
              },
            ),
          );
        }
        return CenterLoadingIndicator();
      },
    );
  }
}
