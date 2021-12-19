import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthome/board/bloc/blocs.dart';
import 'package:smarthome/board/model/models.dart';
import 'package:smarthome/board/repository/board_repository.dart';
import 'package:smarthome/board/view/topic_edit_page.dart';
import 'package:smarthome/board/view/widgets/topic_item.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/widgets/center_loading_indicator.dart';
import 'package:smarthome/widgets/error_message_button.dart';
import 'package:smarthome/widgets/home_page.dart';
import 'package:smarthome/widgets/infinite_list.dart';

class BoardHomePage extends Page {
  const BoardHomePage()
      : super(
          key: const ValueKey('board'),
          name: '/board',
        );

  @override
  Route createRoute(BuildContext context) {
    BlocProvider.of<BoardHomeBloc>(context).add(const BoardHomeFetched());
    return PageRouteBuilder(
      settings: this,
      pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) =>
          FadeTransition(
        opacity: animation,
        child: const BoardHomeScreen(),
      ),
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
      body: const _BoardHomeBody(),
      floatingActionButton: FloatingActionButton(
        tooltip: '添加话题',
        onPressed: () async {
          final r = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => TopicEditBloc(
                    boardRepository:
                        RepositoryProvider.of<BoardRepository>(context)),
                child: const TopicEditPage(
                  isEditing: false,
                ),
              ),
            ),
          );
          if (r) {
            BlocProvider.of<BoardHomeBloc>(context)
                .add(const BoardHomeFetched(cache: false));
          }
        },
        child: const Icon(Icons.create),
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
                  .add(const BoardHomeFetched(cache: false));
            },
            message: state.message,
          );
        }
        if (state is BoardHomeSuccess) {
          // 从各种类型详情页返回
          return RefreshIndicator(
            onRefresh: () async {
              BlocProvider.of<BoardHomeBloc>(context)
                  .add(const BoardHomeFetched(cache: false));
            },
            child: InfiniteList<Topic>(
              items: state.topics,
              hasReachedMax: state.hasReachedMax,
              itemBuilder: (context, item) => TopicItem(topic: item),
              onFetch: () {
                BlocProvider.of<BoardHomeBloc>(context)
                    .add(const BoardHomeFetched());
              },
            ),
          );
        }
        return const CenterLoadingIndicator();
      },
    );
  }
}
