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
    return BlocBuilder<BoardHomeBloc, BoardHomeState>(
      builder: (context, state) {
        return MySliverHomePage(
          activeTab: AppTab.board,
          floatingActionButton: FloatingActionButton(
            tooltip: '添加话题',
            onPressed: () async {
              final boardHomeBloc = context.read<BoardHomeBloc>();

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
              if (r == true) {
                boardHomeBloc.add(const BoardHomeFetched(cache: false));
              }
            },
            child: const Icon(Icons.create),
          ),
          slivers: [
            if (state.status == BoardHomeStatus.failure)
              SliverFillRemaining(
                child: ErrorMessageButton(
                  onPressed: () {
                    BlocProvider.of<BoardHomeBloc>(context)
                        .add(const BoardHomeFetched(cache: false));
                  },
                  message: state.error,
                ),
              ),
            if (state.status == BoardHomeStatus.loading)
              const SliverFillRemaining(child: CenterLoadingIndicator()),
            if (state.status == BoardHomeStatus.success)
              SliverInfiniteList<Topic>(
                items: state.topics,
                hasReachedMax: state.hasReachedMax,
                itemBuilder: (context, item) => TopicItem(topic: item),
                onFetch: () {
                  BlocProvider.of<BoardHomeBloc>(context)
                      .add(const BoardHomeFetched());
                },
              ),
          ],
          onRefresh: () async {
            BlocProvider.of<BoardHomeBloc>(context)
                .add(const BoardHomeFetched(cache: false));
          },
        );
      },
    );
  }
}
