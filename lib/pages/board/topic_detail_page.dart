import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smart_home/blocs/board/blocs.dart';
import 'package:smart_home/blocs/board/topic_detail/topic_detail_bloc.dart';
import 'package:smart_home/pages/board/topic_edit_page.dart';
import 'package:smart_home/pages/board/widgets/add_comment_bar.dart';
import 'package:smart_home/pages/board/widgets/comment_list.dart';
import 'package:smart_home/pages/board/widgets/topic_item.dart';
import 'package:smart_home/pages/error_page.dart';
import 'package:smart_home/pages/loading_page.dart';
import 'package:smart_home/repositories/board_repository.dart';
import 'package:smart_home/widgets/show_snack_bar.dart';

class TopicDetailPage extends StatelessWidget {
  final String topicId;

  const TopicDetailPage({
    Key key,
    @required this.topicId,
  }) : super(key: key);

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

class _TopicDetailPage extends StatefulWidget {
  const _TopicDetailPage({
    Key key,
  }) : super(key: key);

  @override
  __TopicDetailPageState createState() => __TopicDetailPageState();
}

class __TopicDetailPageState extends State<_TopicDetailPage> {
  final _buttonBarController = TextEditingController();
  final _buttonBarFocusNode = FocusNode();

  @override
  void dispose() {
    _buttonBarController.dispose();
    _buttonBarFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TopicDetailBloc, TopicDetailState>(
      builder: (context, state) {
        if (state is TopicDetailFailure) {
          return Scaffold(
            appBar: AppBar(),
            body: ErrorPage(
              onPressed: () {
                BlocProvider.of<TopicDetailBloc>(context).add(
                  TopicDetailChanged(topicId: state.topicId),
                );
              },
              message: state.message,
            ),
          );
        }
        if (state is TopicDetailSuccess) {
          return BlocProvider(
            create: (context) => CommentEditBloc(
              boardRepository: RepositoryProvider.of<BoardRepository>(context),
            ),
            child: Scaffold(
              appBar: AppBar(
                actions: <Widget>[
                  Tooltip(
                    message: '修改',
                    child: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: BlocProvider.of<TopicDetailBloc>(context),
                              child: TopicEditPage(
                                isEditing: true,
                                topic: state.topic,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              body: BlocListener<CommentEditBloc, CommentEditState>(
                listener: (context, state) {
                  // TODO: 更自然的刷新方法
                  if (state is CommentAddSuccess) {
                    _buttonBarController.text = '';
                    _buttonBarFocusNode.unfocus();
                    BlocProvider.of<TopicDetailBloc>(context)
                        .add(TopicDetailRefreshed());
                    showInfoSnackBar('评论成功');
                  }
                  if (state is CommentDeleteSuccess) {
                    BlocProvider.of<TopicDetailBloc>(context)
                        .add(TopicDetailRefreshed());
                    showInfoSnackBar('评论删除成功');
                  }
                },
                child: Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          BlocProvider.of<TopicDetailBloc>(context)
                              .add(TopicDetailRefreshed());
                        },
                        child: GestureDetector(
                          onTap: () {
                            _buttonBarFocusNode.unfocus();
                          },
                          child: CustomScrollView(
                            slivers: <Widget>[
                              SliverToBoxAdapter(
                                child: TopicItem(
                                  topic: state.topic,
                                  showBody: true,
                                ),
                              ),
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 0, 16, 0),
                                  child: Text('全部评论',
                                      style: TextStyle(fontSize: 20)),
                                ),
                              ),
                              SliverCommentList(comments: state.comments),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.bottomCenter,
                      child: AddCommentButtonBar(
                        topic: state.topic,
                        controller: _buttonBarController,
                        focusNode: _buttonBarFocusNode,
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(),
          body: LoadingPage(),
        );
      },
    );
  }
}
