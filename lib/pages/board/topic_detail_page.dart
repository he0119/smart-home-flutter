import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import 'package:smarthome/blocs/core/blocs.dart';
import 'package:smarthome/blocs/board/blocs.dart';
import 'package:smarthome/blocs/board/topic_detail/topic_detail_bloc.dart';
import 'package:smarthome/models/models.dart';
import 'package:smarthome/pages/board/topic_edit_page.dart';
import 'package:smarthome/pages/board/widgets/add_comment_bar.dart';
import 'package:smarthome/pages/board/widgets/comment_item.dart';
import 'package:smarthome/pages/board/widgets/topic_item.dart';
import 'package:smarthome/repositories/board_repository.dart';
import 'package:smarthome/widgets/center_loading_indicator.dart';
import 'package:smarthome/widgets/error_message_button.dart';
import 'package:smarthome/utils/show_snack_bar.dart';
import 'package:smarthome/widgets/infinite_list.dart';

class TopicDetailPage extends Page {
  final String? topicId;

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
  final String? topicId;

  const TopicDetailScreen({
    Key? key,
    required this.topicId,
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

class _DetailScreen extends StatelessWidget {
  const _DetailScreen({
    Key? key,
  }) : super(key: key);

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
              message: state.toString(),
            ),
          );
        }
        if (state is TopicDetailSuccess) {
          return BlocProvider(
            create: (context) => CommentEditBloc(
              boardRepository: RepositoryProvider.of<BoardRepository>(context),
            ),
            child: MultiBlocListener(
              listeners: [
                BlocListener<TopicEditBloc, TopicEditState>(
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
                ),
                BlocListener<CommentEditBloc, CommentEditState>(
                  listener: (context, state) {
                    if (state is CommentDeleteSuccess) {
                      BlocProvider.of<TopicDetailBloc>(context)
                          .add(TopicDetailFetched(
                        descending: descending,
                        cache: false,
                      ));
                      showInfoSnackBar('评论删除成功');
                    }
                    if (state is CommentFailure) {
                      showErrorSnackBar(state.message);
                    }
                  },
                ),
              ],
              child: KeyboardDismissOnTap(
                child: Scaffold(
                  appBar: _buildAppBar(context, state, descending, loginUser),
                  body: RefreshIndicator(
                    onRefresh: () async {
                      BlocProvider.of<TopicDetailBloc>(context)
                          .add(TopicDetailFetched(
                        descending: descending,
                        cache: false,
                      ));
                    },
                    child: InfiniteList<Comment>(
                      items: state.comments,
                      itemBuilder: (context, item) => CommentItem(
                        comment: item,
                        showMenu: loginUser == item.user,
                      ),
                      onFetch: () {
                        context.read<TopicDetailBloc>().add(TopicDetailFetched(
                              topicId: state.topic.id,
                              descending: descending,
                            ));
                      },
                      hasReachedMax: state.hasReachedMax,
                      top: [
                        TopicItem(
                          topic: state.topic,
                          showBody: true,
                        ),
                        CommentOrder(
                          topicId: state.topic.id,
                          descending: descending,
                        ),
                      ],
                    ),
                  ),
                  bottomNavigationBar: Transform.translate(
                    offset: MediaQuery.of(context).viewInsets.bottom == 0
                        ? Offset(0.0, 0.0)
                        : Offset(
                            0.0, -1 * MediaQuery.of(context).viewInsets.bottom),
                    child: AddCommentButtonBar(
                      topic: state.topic,
                      onAddSuccess: () => context
                          .read<TopicDetailBloc>()
                          .add(TopicDetailFetched(
                            descending: descending,
                            cache: false,
                            showInProgress: false,
                          )),
                    ),
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

  AppBar _buildAppBar(
    BuildContext context,
    TopicDetailSuccess state,
    bool descending,
    User? loginUser,
  ) {
    return AppBar(
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
                            RepositoryProvider.of<BoardRepository>(context)),
                    child: TopicEditPage(
                      isEditing: true,
                      topic: state.topic,
                    ),
                  ),
                ),
              );
              BlocProvider.of<TopicDetailBloc>(context).add(TopicDetailFetched(
                descending: descending,
                cache: false,
              ));
            }
            if (value == TopicDetailMenu.delete) {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('删除话题'),
                  content: Text('你确认要删除该话题？'),
                  actions: <Widget>[
                    TextButton(
                      child: Text('否'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
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
                    TextButton(
                      child: Text('否'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
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
                    TextButton(
                      child: Text('否'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
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
                    TextButton(
                      child: Text('否'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
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
                    TextButton(
                      child: Text('否'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
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
            if (!state.topic.isPin!)
              PopupMenuItem(
                value: TopicDetailMenu.pin,
                child: Text('置顶'),
              ),
            if (state.topic.isPin!)
              PopupMenuItem(
                value: TopicDetailMenu.unpin,
                child: Text('取消置顶'),
              ),
            if (state.topic.isOpen!)
              PopupMenuItem(
                value: TopicDetailMenu.close,
                child: Text('关闭'),
              ),
            if (!state.topic.isOpen!)
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
    );
  }
}

class CommentOrder extends StatelessWidget {
  const CommentOrder({
    Key? key,
    required this.topicId,
    required this.descending,
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
            onSelected: (dynamic value) {
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
