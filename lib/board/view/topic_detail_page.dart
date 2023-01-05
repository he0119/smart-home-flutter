import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthome/app/settings/settings_controller.dart';
import 'package:smarthome/board/bloc/blocs.dart';
import 'package:smarthome/board/model/models.dart';
import 'package:smarthome/board/repository/board_repository.dart';
import 'package:smarthome/board/view/comment_edit_page.dart';
import 'package:smarthome/board/view/topic_edit_page.dart';
import 'package:smarthome/board/view/widgets/comment_item.dart';
import 'package:smarthome/board/view/widgets/item_title.dart';
import 'package:smarthome/utils/show_snack_bar.dart';
import 'package:smarthome/widgets/center_loading_indicator.dart';
import 'package:smarthome/widgets/error_message_button.dart';
import 'package:smarthome/widgets/home_page.dart';
import 'package:smarthome/widgets/infinite_list.dart';
import 'package:smarthome/widgets/markdown.dart';

class TopicDetailPage extends Page {
  final String topicId;

  TopicDetailPage({
    required this.topicId,
  }) : super(key: ValueKey(topicId), name: '/topic/$topicId');

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) {
        final descending = context.select(
            (SettingsController settings) => settings.commentDescending);
        return MultiBlocProvider(
          providers: [
            BlocProvider<TopicDetailBloc>(
              create: (context) => TopicDetailBloc(
                boardRepository: context.read<BoardRepository>(),
              )..add(TopicDetailFetched(id: topicId, descending: descending)),
            ),
            BlocProvider<TopicEditBloc>(
              create: (context) => TopicEditBloc(
                boardRepository: context.read<BoardRepository>(),
              ),
            ),
            BlocProvider(
              create: (context) => CommentEditBloc(
                boardRepository: context.read<BoardRepository>(),
              ),
            )
          ],
          child: TopicDetailScreen(
            topicId: topicId,
          ),
        );
      },
    );
  }
}

class TopicDetailScreen extends StatelessWidget {
  final String topicId;

  const TopicDetailScreen({
    Key? key,
    required this.topicId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loginUser =
        context.select((SettingsController settings) => settings.loginUser);
    final descending = context
        .select((SettingsController settings) => settings.commentDescending);
    return MultiBlocListener(
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
              context.read<TopicDetailBloc>().add(TopicDetailFetched(
                    id: topicId,
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
      child: BlocBuilder<TopicDetailBloc, TopicDetailState>(
        builder: (context, state) {
          return SelectionArea(
            child: MySliverScaffold(
              title: Text(state.topic.title ?? ''),
              actions: <Widget>[
                PopupMenuButton<TopicDetailMenu>(
                  onSelected: (value) async {
                    final topicDetailBloc = context.read<TopicDetailBloc>();
                    if (value == TopicDetailMenu.edit) {
                      final r = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (context) => TopicEditBloc(
                                boardRepository:
                                    context.read<BoardRepository>()),
                            child: TopicEditPage(
                              isEditing: true,
                              topic: state.topic,
                            ),
                          ),
                        ),
                      );
                      if (r == true) {
                        topicDetailBloc.add(
                          TopicDetailFetched(
                              id: topicId,
                              descending: descending,
                              cache: false),
                        );
                      }
                    }
                    if (value == TopicDetailMenu.delete) {
                      await showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('删除话题'),
                          content: const Text('你确认要删除该话题？'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('否'),
                            ),
                            TextButton(
                              onPressed: () {
                                showInfoSnackBar('正在删除...', duration: 1);
                                context
                                    .read<TopicEditBloc>()
                                    .add(TopicDeleted(topic: state.topic));
                                Navigator.of(context).pop();
                              },
                              child: const Text('是'),
                            ),
                          ],
                        ),
                      );
                    }
                    if (value == TopicDetailMenu.pin) {
                      await showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('置顶话题'),
                          content: const Text('你确认要置顶该话题？'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('否'),
                            ),
                            TextButton(
                              onPressed: () {
                                showInfoSnackBar('正在置顶...', duration: 1);
                                context
                                    .read<TopicEditBloc>()
                                    .add(TopicPinned(topic: state.topic));
                                Navigator.of(context).pop();
                              },
                              child: const Text('是'),
                            ),
                          ],
                        ),
                      );
                    }
                    if (value == TopicDetailMenu.unpin) {
                      await showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('取消置顶'),
                          content: const Text('你确认要取消该话题的置顶？'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('否'),
                            ),
                            TextButton(
                              onPressed: () {
                                showInfoSnackBar('正在取消...', duration: 1);
                                context
                                    .read<TopicEditBloc>()
                                    .add(TopicUnpinned(topic: state.topic));
                                Navigator.of(context).pop();
                              },
                              child: const Text('是'),
                            ),
                          ],
                        ),
                      );
                    }
                    if (value == TopicDetailMenu.close) {
                      await showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('关闭话题'),
                          content: const Text('你确认要关闭该话题？'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('否'),
                            ),
                            TextButton(
                              onPressed: () {
                                showInfoSnackBar('正在关闭...', duration: 1);
                                context
                                    .read<TopicEditBloc>()
                                    .add(TopicClosed(topic: state.topic));
                                Navigator.of(context).pop();
                              },
                              child: const Text('是'),
                            ),
                          ],
                        ),
                      );
                    }
                    if (value == TopicDetailMenu.reopen) {
                      await showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('开启话题'),
                          content: const Text('你确认要重新开启该话题？'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('否'),
                            ),
                            TextButton(
                              onPressed: () {
                                showInfoSnackBar('正在开启...', duration: 1);
                                context
                                    .read<TopicEditBloc>()
                                    .add(TopicReopened(topic: state.topic));
                                Navigator.of(context).pop();
                              },
                              child: const Text('是'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    if (!state.topic.isPinned!)
                      const PopupMenuItem(
                        value: TopicDetailMenu.pin,
                        child: Text('置顶'),
                      ),
                    if (state.topic.isPinned!)
                      const PopupMenuItem(
                        value: TopicDetailMenu.unpin,
                        child: Text('取消置顶'),
                      ),
                    if (!state.topic.isClosed!)
                      const PopupMenuItem(
                        value: TopicDetailMenu.close,
                        child: Text('关闭'),
                      ),
                    if (state.topic.isClosed!)
                      const PopupMenuItem(
                        value: TopicDetailMenu.reopen,
                        child: Text('开启'),
                      ),
                    if (!state.topic.isClosed! && loginUser == state.topic.user)
                      const PopupMenuItem(
                        value: TopicDetailMenu.edit,
                        child: Text('编辑'),
                      ),
                    if (!state.topic.isClosed! && loginUser == state.topic.user)
                      const PopupMenuItem(
                        value: TopicDetailMenu.delete,
                        child: Text('删除'),
                      ),
                  ],
                ),
              ],
              slivers: [
                if (state.topic.description != null)
                  SliverToBoxAdapter(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ItemTitle(
                          user: state.topic.user!,
                          createdAt: state.topic.createdAt!,
                          editedAt: state.topic.editedAt!,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: MyMarkdownBody(
                            data: state.topic.description!,
                          ),
                        ),
                      ],
                    ),
                  ),
                SliverToBoxAdapter(
                  child: CommentOrder(
                    topicId: state.topic.id,
                    descending: descending,
                  ),
                ),
                if (state.status == TopicDetailStatus.failure)
                  SliverErrorMessageButton(
                    onPressed: () {
                      context.read<TopicDetailBloc>().add(
                            TopicDetailFetched(
                                id: topicId, descending: descending),
                          );
                    },
                    message: state.error,
                  ),
                if (state.status == TopicDetailStatus.loading)
                  const SliverCenterLoadingIndicator(),
                if (state.status == TopicDetailStatus.success)
                  SliverInfiniteList<Comment>(
                    items: state.comments,
                    itemBuilder: (context, item) => CommentItem(
                      comment: item,
                      showMenu: loginUser == item.user,
                      onEdit: () {
                        context.read<TopicDetailBloc>().add(TopicDetailFetched(
                              id: state.topic.id,
                              descending: descending,
                            ));
                      },
                    ),
                    onFetch: () {
                      context.read<TopicDetailBloc>().add(TopicDetailFetched(
                            id: state.topic.id,
                            descending: descending,
                            cache: false,
                          ));
                    },
                    hasReachedMax: state.hasReachedMax,
                  )
              ],
              onRefresh: () async {
                context.read<TopicDetailBloc>().add(TopicDetailFetched(
                      id: state.topic.id,
                      descending: descending,
                      cache: false,
                    ));
              },
              floatingActionButton: (state.status ==
                          TopicDetailStatus.success &&
                      state.topic.isClosed!)
                  ? null
                  : FloatingActionButton(
                      tooltip: '添加评论',
                      child: const Icon(Icons.add_comment),
                      onPressed: () async {
                        final topicDetailBloc = context.read<TopicDetailBloc>();

                        final r = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BlocProvider(
                              create: (context) => CommentEditBloc(
                                  boardRepository:
                                      context.read<BoardRepository>()),
                              child: CommentEditPage(
                                isEditing: false,
                                topic: state.topic,
                              ),
                            ),
                          ),
                        );
                        if (r == true) {
                          topicDetailBloc.add(
                            TopicDetailFetched(
                              id: topicId,
                              descending: descending,
                              cache: false,
                              showInProgress: false,
                            ),
                          );
                        }
                      },
                    ),
            ),
          );
        },
      ),
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
          const Text(
            '全部评论',
            style: TextStyle(fontSize: 16),
          ),
          const Spacer(),
          PopupMenuButton(
            tooltip: '评论排序',
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Icon(Icons.sort),
                  const SizedBox(width: 4),
                  Text(descending ? '倒序' : '正序'),
                ],
              ),
            ),
            onSelected: (dynamic value) {
              context.read<SettingsController>().updateCommentDescending(value);
              context.read<TopicDetailBloc>().add(
                    TopicDetailFetched(id: topicId, descending: value),
                  );
            },
            itemBuilder: (context) => <PopupMenuItem<bool>>[
              const PopupMenuItem(
                value: false,
                child: Text('正序'),
              ),
              const PopupMenuItem(
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
