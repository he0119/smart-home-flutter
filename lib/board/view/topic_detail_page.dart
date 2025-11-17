import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/board/model/models.dart';
import 'package:smarthome/board/providers/comment_edit_provider.dart';
import 'package:smarthome/board/providers/topic_detail_provider.dart';
import 'package:smarthome/board/providers/topic_edit_provider.dart';
import 'package:smarthome/board/view/comment_edit_page.dart';
import 'package:smarthome/board/view/topic_edit_page.dart';
import 'package:smarthome/board/view/widgets/comment_item.dart';
import 'package:smarthome/board/view/widgets/item_title.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/utils/show_snack_bar.dart';
import 'package:smarthome/widgets/center_loading_indicator.dart';
import 'package:smarthome/widgets/error_message_button.dart';
import 'package:smarthome/widgets/home_page.dart';
import 'package:smarthome/widgets/infinite_list.dart';
import 'package:smarthome/widgets/markdown.dart';

class TopicDetailPage extends Page {
  final String topicId;

  TopicDetailPage({required this.topicId})
    : super(key: ValueKey(topicId), name: '/topic/$topicId');

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) {
        return TopicDetailScreen(topicId: topicId);
      },
    );
  }
}

class TopicDetailScreen extends ConsumerStatefulWidget {
  final String topicId;

  const TopicDetailScreen({super.key, required this.topicId});

  @override
  ConsumerState<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends ConsumerState<TopicDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final descending = ref.read(settingsProvider).commentDescending;
      ref
          .read(topicDetailProvider(widget.topicId).notifier)
          .initialize(descending: descending);
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final loginUser = settings.loginUser;
    final descending = settings.commentDescending;

    // Listen to TopicEdit state changes
    ref.listen<TopicEditState>(topicEditProvider, (previous, state) {
      if (state.status == TopicEditStatus.deleteSuccess) {
        showInfoSnackBar('话题 ${state.topic!.title} 删除成功');
        Navigator.of(context).pop();
      }
      if (state.status == TopicEditStatus.pinSuccess) {
        showInfoSnackBar('话题 ${state.topic!.title} 置顶成功');
      }
      if (state.status == TopicEditStatus.unpinSuccess) {
        showInfoSnackBar('话题 ${state.topic!.title} 已取消置顶');
      }
      if (state.status == TopicEditStatus.closeSuccess) {
        showInfoSnackBar('话题 ${state.topic!.title} 关闭成功');
      }
      if (state.status == TopicEditStatus.reopenSuccess) {
        showInfoSnackBar('话题 ${state.topic!.title} 开启成功');
      }
      if (state.status == TopicEditStatus.failure) {
        showErrorSnackBar(state.errorMessage);
      }
    });

    // Listen to CommentEdit state changes
    ref.listen<CommentEditState>(commentEditProvider, (previous, state) {
      if (state.status == CommentEditStatus.deleteSuccess) {
        ref
            .read(topicDetailProvider(widget.topicId).notifier)
            .refresh(descending: descending);
        showInfoSnackBar('评论删除成功');
      }
      if (state.status == CommentEditStatus.failure) {
        showErrorSnackBar(state.errorMessage);
      }
    });

    final state = ref.watch(topicDetailProvider(widget.topicId));

    return MySliverScaffold(
      title: Text(state.topic.title ?? ''),
      actions: <Widget>[
        PopupMenuButton<TopicDetailMenu>(
          onSelected: (value) async {
            if (value == TopicDetailMenu.edit) {
              final r = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      TopicEditPage(isEditing: true, topic: state.topic),
                ),
              );
              if (r == true) {
                ref
                    .read(topicDetailProvider(widget.topicId).notifier)
                    .refresh(descending: descending);
              }
            }

            if (value == TopicDetailMenu.delete) {
              if (context.mounted) {
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
                          ref
                              .read(topicEditProvider.notifier)
                              .deleteTopic(state.topic);
                          Navigator.of(context).pop();
                        },
                        child: const Text('是'),
                      ),
                    ],
                  ),
                );
              }
            }
            if (value == TopicDetailMenu.pin) {
              if (context.mounted) {
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
                          ref
                              .read(topicEditProvider.notifier)
                              .pinTopic(state.topic);
                          Navigator.of(context).pop();
                        },
                        child: const Text('是'),
                      ),
                    ],
                  ),
                );
              }
            }
            if (value == TopicDetailMenu.unpin) {
              if (context.mounted) {
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
                          ref
                              .read(topicEditProvider.notifier)
                              .unpinTopic(state.topic);
                          Navigator.of(context).pop();
                        },
                        child: const Text('是'),
                      ),
                    ],
                  ),
                );
              }
            }
            if (value == TopicDetailMenu.close) {
              if (context.mounted) {
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
                          ref
                              .read(topicEditProvider.notifier)
                              .closeTopic(state.topic);
                          Navigator.of(context).pop();
                        },
                        child: const Text('是'),
                      ),
                    ],
                  ),
                );
              }
            }
            if (value == TopicDetailMenu.reopen) {
              if (context.mounted) {
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
                          ref
                              .read(topicEditProvider.notifier)
                              .reopenTopic(state.topic);
                          Navigator.of(context).pop();
                        },
                        child: const Text('是'),
                      ),
                    ],
                  ),
                );
              }
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
                  child: MyMarkdownBody(data: state.topic.description!),
                ),
              ],
            ),
          ),
        SliverToBoxAdapter(
          child: CommentOrder(topicId: state.topic.id, descending: descending),
        ),
        if (state.status == TopicDetailStatus.failure)
          SliverErrorMessageButton(
            onPressed: () {
              ref
                  .read(topicDetailProvider(widget.topicId).notifier)
                  .refresh(descending: descending);
            },
            message: state.errorMessage,
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
                ref
                    .read(topicDetailProvider(widget.topicId).notifier)
                    .refresh(descending: descending);
              },
            ),
            onFetch: () {
              ref
                  .read(topicDetailProvider(widget.topicId).notifier)
                  .fetchMore(descending: descending);
            },
            hasReachedMax: state.hasReachedMax,
          ),
      ],
      onRefresh: () async {
        ref
            .read(topicDetailProvider(widget.topicId).notifier)
            .refresh(descending: descending);
      },
      floatingActionButton:
          (state.status == TopicDetailStatus.success && state.topic.isClosed!)
          ? null
          : FloatingActionButton(
              tooltip: '添加评论',
              child: const Icon(Icons.add_comment),
              onPressed: () async {
                final r = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        CommentEditPage(isEditing: false, topic: state.topic),
                  ),
                );
                if (r == true) {
                  ref
                      .read(topicDetailProvider(widget.topicId).notifier)
                      .refresh(descending: descending);
                }
              },
            ),
    );
  }
}

class CommentOrder extends ConsumerWidget {
  const CommentOrder({
    super.key,
    required this.topicId,
    required this.descending,
  });

  final String topicId;
  final bool descending;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        children: [
          const Divider(),
          Row(
            children: <Widget>[
              const Text('全部评论', style: TextStyle(fontSize: 16)),
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
                  ref
                      .read(settingsProvider.notifier)
                      .updateCommentDescending(value);
                  ref
                      .read(topicDetailProvider(topicId).notifier)
                      .refresh(descending: value);
                },
                itemBuilder: (context) => <PopupMenuItem<bool>>[
                  const PopupMenuItem(value: false, child: Text('正序')),
                  const PopupMenuItem(value: true, child: Text('倒序')),
                ],
              ),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }
}
