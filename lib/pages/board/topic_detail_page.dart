import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smart_home/blocs/core/blocs.dart';
import 'package:smart_home/blocs/board/blocs.dart';
import 'package:smart_home/blocs/board/topic_detail/topic_detail_bloc.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/pages/board/topic_edit_page.dart';
import 'package:smart_home/pages/board/widgets/add_comment_bar.dart';
import 'package:smart_home/pages/board/widgets/comment_list.dart';
import 'package:smart_home/pages/board/widgets/topic_item.dart';
import 'package:smart_home/repositories/board_repository.dart';
import 'package:smart_home/widgets/center_loading_indicator.dart';
import 'package:smart_home/widgets/error_message_button.dart';
import 'package:smart_home/utils/show_snack_bar.dart';

class TopicDetailPage extends Page {
  final String topicId;

  TopicDetailPage({
    this.topicId,
  }) : super(key: ValueKey(topicId), name: '/topic/$topicId');

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (context) => TopicDetailScreen(
        topicId: topicId,
      ),
    );
  }
}

class TopicDetailScreen extends StatelessWidget {
  final String topicId;

  const TopicDetailScreen({
    Key key,
    @required this.topicId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final descending =
        context.select((AppPreferencesBloc b) => b.state.commentDescending);
    return MultiBlocProvider(
      providers: [
        BlocProvider<TopicDetailBloc>(
          create: (context) => TopicDetailBloc(
            boardRepository: RepositoryProvider.of<BoardRepository>(context),
          )..add(TopicDetailFetched(topicId: topicId, descending: descending)),
        ),
        BlocProvider<TopicEditBloc>(
          create: (context) => TopicEditBloc(
            boardRepository: RepositoryProvider.of<BoardRepository>(context),
          ),
        )
      ],
      child: _DetailScreen(),
    );
  }
}

class _DetailScreen extends StatefulWidget {
  const _DetailScreen({
    Key key,
  }) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<_DetailScreen> {
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
    final descending =
        context.select((AppPreferencesBloc b) => b.state.commentDescending);
    return BlocBuilder<TopicDetailBloc, TopicDetailState>(
      builder: (context, state) {
        if (state is TopicDetailFailure) {
          return Scaffold(
            appBar: AppBar(),
            body: ErrorMessageButton(
              onPressed: () {
                BlocProvider.of<TopicDetailBloc>(context).add(
                  TopicDetailFetched(
                      topicId: state.topicId, descending: descending),
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
                if (state is TopicPinSuccess) {
                  showInfoSnackBar('话题 ${state.topic.title} 置顶成功');
                }
                if (state is TopicUnpinSuccess) {
                  showInfoSnackBar('话题 ${state.topic.title} 已取消置顶');
                }
                if (state is TopicCloseSuccess) {
                  showInfoSnackBar('话题 ${state.topic.title} 关闭成功');
                }
                if (state is TopicReopenSuccess) {
                  showInfoSnackBar('话题 ${state.topic.title} 开启成功');
                }
                if (state is TopicFailure) {
                  showErrorSnackBar(state.message);
                }
              },
              child: Scaffold(
                appBar: AppBar(
                  actions: <Widget>[
                    PopupMenuButton<TopicDetailMenu>(
                      onSelected: (value) async {
                        if (value == TopicDetailMenu.edit) {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider(
                                create: (context) => TopicEditBloc(
                                    boardRepository:
                                        RepositoryProvider.of<BoardRepository>(
                                            context)),
                                child: TopicEditPage(
                                  isEditing: true,
                                  topic: state.topic,
                                ),
                              ),
                            ),
                          );
                          BlocProvider.of<TopicDetailBloc>(context)
                              .add(TopicDetailFetched(
                            topicId: state.topic.id,
                            descending: descending,
                            refresh: true,
                          ));
                        }
                        if (value == TopicDetailMenu.delete) {
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
                                        .add(TopicDeleted(topic: state.topic));
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          );
                        }
                        if (value == TopicDetailMenu.pin) {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text('置顶话题'),
                              content: Text('你确认要置顶该话题？'),
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
                                    showInfoSnackBar('正在置顶...', duration: 1);
                                    BlocProvider.of<TopicEditBloc>(context)
                                        .add(TopicPinned(topic: state.topic));
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          );
                        }
                        if (value == TopicDetailMenu.unpin) {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text('取消置顶'),
                              content: Text('你确认要取消该话题的置顶？'),
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
                                    showInfoSnackBar('正在取消...', duration: 1);
                                    BlocProvider.of<TopicEditBloc>(context)
                                        .add(TopicUnpinned(topic: state.topic));
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          );
                        }
                        if (value == TopicDetailMenu.close) {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text('关闭话题'),
                              content: Text('你确认要关闭该话题？'),
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
                                    showInfoSnackBar('正在关闭...', duration: 1);
                                    BlocProvider.of<TopicEditBloc>(context)
                                        .add(TopicClosed(topic: state.topic));
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          );
                        }
                        if (value == TopicDetailMenu.reopen) {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text('开启话题'),
                              content: Text('你确认要重新开启该话题？'),
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
                                    showInfoSnackBar('正在开启...', duration: 1);
                                    BlocProvider.of<TopicEditBloc>(context)
                                        .add(TopicReopened(topic: state.topic));
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        if (!state.topic.isPin)
                          PopupMenuItem(
                            value: TopicDetailMenu.pin,
                            child: Text('置顶'),
                          ),
                        if (state.topic.isPin)
                          PopupMenuItem(
                            value: TopicDetailMenu.unpin,
                            child: Text('取消置顶'),
                          ),
                        if (state.topic.isOpen)
                          PopupMenuItem(
                            value: TopicDetailMenu.close,
                            child: Text('关闭'),
                          ),
                        if (!state.topic.isOpen)
                          PopupMenuItem(
                            value: TopicDetailMenu.reopen,
                            child: Text('开启'),
                          ),
                        if (loginUser == state.topic.user)
                          PopupMenuItem(
                            value: TopicDetailMenu.edit,
                            child: Text('编辑'),
                          ),
                        if (loginUser == state.topic.user)
                          PopupMenuItem(
                            value: TopicDetailMenu.delete,
                            child: Text('删除'),
                          ),
                      ],
                    ),
                  ],
                ),
                body: BlocListener<CommentEditBloc, CommentEditState>(
                  listener: (context, state) {
                    if (state is CommentAddSuccess) {
                      _buttonBarController.text = '';
                      _buttonBarFocusNode.unfocus();
                      BlocProvider.of<TopicDetailBloc>(context)
                          .add(TopicDetailFetched(
                        topicId: state.comment.topic.id,
                        descending: descending,
                        refresh: true,
                      ));
                      showInfoSnackBar('评论成功');
                    }
                    if (state is CommentDeleteSuccess) {
                      BlocProvider.of<TopicDetailBloc>(context)
                          .add(TopicDetailFetched(
                        topicId: state.comment.topic.id,
                        descending: descending,
                        refresh: true,
                      ));
                      showInfoSnackBar('评论删除成功');
                    }
                    if (state is CommentFailure) {
                      showErrorSnackBar(state.message);
                    }
                  },
                  child: Column(
                    children: [
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            BlocProvider.of<TopicDetailBloc>(context)
                                .add(TopicDetailFetched(
                              topicId: state.topic.id,
                              descending: descending,
                              refresh: true,
                            ));
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
                                  child: CommentOrder(
                                    topicId: state.topic.id,
                                    descending: descending,
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
          body: CenterLoadingIndicator(),
        );
      },
    );
  }
}

class CommentOrder extends StatelessWidget {
  const CommentOrder({
    Key key,
    @required this.topicId,
    @required this.descending,
  }) : super(key: key);

  final String topicId;
  final bool descending;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Row(
        children: <Widget>[
          Text(
            '全部评论',
            style: TextStyle(fontSize: 20),
          ),
          Spacer(),
          PopupMenuButton(
            tooltip: '评论排序',
            icon: Icon(
              descending ? Icons.arrow_downward : Icons.arrow_upward,
            ),
            onSelected: (value) {
              BlocProvider.of<AppPreferencesBloc>(context)
                  .add(CommentDescendingChanged(descending: value));
              BlocProvider.of<TopicDetailBloc>(context)
                  .add(TopicDetailFetched(topicId: topicId, descending: value));
            },
            itemBuilder: (context) => <PopupMenuItem<bool>>[
              PopupMenuItem(
                value: false,
                child: Text('正序'),
              ),
              PopupMenuItem(
                value: true,
                child: Text('倒序'),
              ),
            ],
          )
        ],
      ),
    );
  }
}
