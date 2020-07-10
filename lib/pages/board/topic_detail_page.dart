import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/board/blocs.dart';
import 'package:smart_home/blocs/board/topic_detail/topic_detail_bloc.dart';
import 'package:smart_home/pages/board/widgets/add_comment_bar.dart';
import 'package:smart_home/pages/board/widgets/comment_list.dart';
import 'package:smart_home/pages/board/widgets/topic_item.dart';
import 'package:smart_home/repositories/board_repository.dart';

class TopicDetailPage extends StatelessWidget {
  static const routeName = '/topic';

  final String topicId;

  const TopicDetailPage({Key key, @required this.topicId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TopicDetailBloc(
        boardRepository: RepositoryProvider.of<BoardRepository>(context),
      )..add(TopicDetailChanged(topicId: topicId)),
      child: _TopicDetailPage(),
    );
  }
}

class _TopicDetailPage extends StatelessWidget {
  const _TopicDetailPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TopicDetailBloc, TopicDetailState>(
      builder: (context, state) {
        if (state is TopicDetailInProgress) {
          return Scaffold(
              appBar: AppBar(),
              body: Center(child: CircularProgressIndicator()));
        }
        if (state is TopicDetailFailure) {
          return Scaffold(
            appBar: AppBar(
              title: Text('错误'),
            ),
            body: Center(child: Text(state.message)),
          );
        }
        if (state is TopicDetailSuccess) {
          return BlocProvider(
            create: (context) => CommentBloc(
              boardRepository: RepositoryProvider.of<BoardRepository>(context),
            ),
            child: Scaffold(
              appBar: AppBar(),
              body: RefreshIndicator(
                onRefresh: () async {
                  BlocProvider.of<TopicDetailBloc>(context)
                      .add(TopicDetailRefreshed(topicId: state.topic.id));
                },
                child: GestureDetector(
                  onTap: () {
                    // Dismiss the keyboard
                    FocusScopeNode currentFocus = FocusScope.of(context);

                    if (!currentFocus.hasPrimaryFocus) {
                      currentFocus.unfocus();
                    }
                  },
                  child: Stack(
                    children: <Widget>[
                      CustomScrollView(
                        slivers: <Widget>[
                          SliverToBoxAdapter(
                            child: TopicItem(
                              topic: state.topic,
                              showBody: true,
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                              child:
                                  Text('全部评论', style: TextStyle(fontSize: 20)),
                            ),
                          ),
                          SliverCommentList(comments: state.comments),
                        ],
                      ),
                      Positioned(
                        bottom: 0.0,
                        left: 0.0,
                        right: 0.0,
                        child: AddCommentButtonBar(
                          topic: state.topic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        return Scaffold();
      },
    );
  }
}
