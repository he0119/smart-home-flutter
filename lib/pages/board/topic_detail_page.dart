import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smart_home/blocs/blocs.dart';
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
    return MultiBlocProvider(
      providers: [
        BlocProvider<TopicDetailBloc>(
          create: (context) => TopicDetailBloc(
            boardRepository: RepositoryProvider.of<BoardRepository>(context),
          )..add(TopicDetailChanged(topicId: topicId)),
        ),
        BlocProvider<TopicEditBloc>(
          create: (context) => TopicEditBloc(
            boardRepository: RepositoryProvider.of<BoardRepository>(context),
          ),
        )
      ],
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
    final loginUser =
        context.select((AppPreferencesBloc b) => b.state.loginUser);
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
            child: BlocListener<TopicEditBloc, TopicEditState>(
              listener: (context, state) {
                if (state is TopicDeleteSuccess) {
                  showInfoSnackBar('话题 ${state.topic.title} 删除成功');
                  Navigator.of(context).pop();
                }
                if (state is TopicFailure) {
                  showErrorSnackBar(state.message);
                }
              },
              child: Scaffold(
                appBar: AppBar(
                  actions: <Widget>[
                    if (loginUser == state.topic.user)
                      Tooltip(
                        message: '删除',
                        child: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () async {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text('删除话题'),
                                content: Text('你确认要删除该话题？'),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text('否'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  FlatButton(
                                    child: Text('是'),
                                    onPressed: () {
                                      showInfoSnackBar('正在删除...', duration: 1);
                                      BlocProvider.of<TopicEditBloc>(context)
                                          .add(
                                              TopicDeleted(topic: state.topic));
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    if (loginUser == state.topic.user)
                      Tooltip(
                        message: '修改',
                        child: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider(
                                  create: (context) => TopicEditBloc(
                                      boardRepository: RepositoryProvider.of<
                                          BoardRepository>(context)),
                                  child: TopicEditPage(
                                    isEditing: true,
                                    topic: state.topic,
                                  ),
                                ),
                              ),
                            );
                            BlocProvider.of<TopicDetailBloc>(context)
                                .add(TopicDetailRefreshed());
                          },
                        ),
                      ),
                  ],
                ),
                body: BlocListener<CommentEditBloc, CommentEditState>(
                  listener: (context, state) {
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
