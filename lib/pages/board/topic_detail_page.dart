import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/board/topic_detail/topic_detail_bloc.dart';
import 'package:smart_home/pages/board/widgets/comment_list.dart';

class TopicDetailPage extends StatelessWidget {
  final String topicId;

  const TopicDetailPage({Key key, @required this.topicId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          TopicDetailBloc()..add(TopicDetailChanged(topicId: topicId)),
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
              appBar: AppBar(
                title: Text('加载中'),
              ),
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
          // 从各种类型详情页返回
          return Scaffold(
            appBar: AppBar(
              title: Text(state.topic.title),
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                BlocProvider.of<TopicDetailBloc>(context)
                    .add(TopicDetailRefreshed(topicId: state.topic.id));
              },
              child: CommentList(comments: state.comments),
            ),
          );
        }
        return Scaffold();
      },
    );
  }
}
