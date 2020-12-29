import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smart_home/blocs/board/blocs.dart';
import 'package:smart_home/models/app_tab.dart';
import 'package:smart_home/pages/board/topic_edit_page.dart';
import 'package:smart_home/pages/board/widgets/topic_item.dart';
import 'package:smart_home/repositories/board_repository.dart';
import 'package:smart_home/widgets/center_loading_indicator.dart';
import 'package:smart_home/widgets/error_message_button.dart';
import 'package:smart_home/widgets/home_page.dart';
import 'package:smart_home/widgets/infinite_list.dart';

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
          BlocProvider.of<BoardHomeBloc>(context)
              .add(BoardHomeFetched(cache: false));
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
              itemBuilder: (context, item) => TopicItem(topic: item),
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
