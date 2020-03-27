import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/board/blocs.dart';
import 'package:smart_home/pages/board/widgets/topic_list.dart';

class BoardHomePage extends StatelessWidget {
  const BoardHomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BoardHomeBloc()..add(BoardHomeStarted()),
      child: _BoardHomePage(),
    );
  }
}

class _BoardHomePage extends StatelessWidget {
  const _BoardHomePage({
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
