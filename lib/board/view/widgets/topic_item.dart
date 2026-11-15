import 'package:material_ui/material_ui.dart';
import 'package:smarthome/board/model/board.dart';

import 'package:smarthome/board/view/widgets/item_title.dart';
import 'package:smarthome/app/dimens.dart';
import 'package:smarthome/core/router/router_extensions.dart';
import 'package:smarthome/utils/date_format_extension.dart';
import 'package:smarthome/widgets/avatar.dart';
import 'package:smarthome/widgets/markdown.dart';
import 'package:flutter/widget_previews.dart';
import 'package:smarthome/widgets/preview_frame.dart';
import 'package:smarthome/user/user.dart';

class TopicItem extends StatelessWidget {
  final Topic topic;
  final bool showBody;

  const TopicItem({super.key, required this.topic, this.showBody = false});

  @override
  Widget build(BuildContext context) {
    // 获取最近互动时间：编辑时间、创建时间、最后一条评论，取最晚的
    DateTime? activeAt = topic.editedAt ?? topic.createdAt;
    final comments = topic.comments;
    final lastCommentAt = (comments != null && comments.isNotEmpty)
        ? comments.last.createdAt
        : null;
    if (lastCommentAt != null &&
        (activeAt == null || activeAt.isBefore(lastCommentAt))) {
      activeAt = lastCommentAt;
    }
    if (showBody) {
      return Column(
        mainAxisAlignment: .start,
        crossAxisAlignment: .start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              topic.title!,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          ItemTitle(
            user: topic.user!,
            createdAt: topic.createdAt!,
            editedAt: topic.editedAt!,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: MyMarkdownBody(data: topic.description!),
          ),
        ],
      );
    } else {
      // 依据话题添加标志
      final colors = Theme.of(context).colorScheme;
      final flags = <Widget>[
        if (topic.isClosed ?? false)
          Icon(
            Icons.lock_outline,
            size: 16,
            color: colors.onSurfaceVariant,
            semanticLabel: '已关闭',
          ),
        if (topic.isPinned ?? false)
          Icon(
            Icons.push_pin_outlined,
            size: 16,
            color: colors.onSurfaceVariant,
            semanticLabel: '已置顶',
          ),
      ];
      // 列表里标题在前、作者和时间压成一行副标题，和物品列表保持一致
      return ListTile(
        leading: MyCircleAvatar(avatarUrl: topic.user?.avatarUrl),
        title: Row(
          crossAxisAlignment: .start,
          children: <Widget>[
            if (flags.isNotEmpty) ...<Widget>[
              ...flags,
              const SizedBox(width: AppSpacing.sm),
            ],
            Expanded(
              child: Text(
                topic.title!,
                maxLines: 2,
                overflow: .ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Text(
          '${topic.user?.username ?? '匿名'} · 最近回复 '
          '${activeAt == null ? '未知' : activeAt.differenceFromNowStr()}',
          maxLines: 1,
          overflow: .ellipsis,
        ),
        onTap: () async {
          context.goTopicDetail(topic.id);
        },
      );
    }
  }
}

/// 开发时在 IDE 里直接看效果，不依赖后端数据。
@Preview(name: 'TopicItem 列表', group: previewGroupBoard, size: Size(400, 240))
Widget topicItemPreview() => PreviewFrame(
  width: 400,
  padding: EdgeInsets.zero,
  child: Column(
    children: <Widget>[
      TopicItem(
        topic: Topic(
          id: 'topic-1',
          title: '阳台储物柜怎么整理比较好？',
          user: const User(username: '橙子', email: 'chengzi@example.com'),
          createdAt: DateTime(2026, 11, 10, 9, 30),
          editedAt: DateTime(2026, 11, 10, 9, 30),
          comments: <Comment>[
            Comment(id: 'comment-1', createdAt: DateTime(2026, 11, 12, 20)),
          ],
        ),
      ),
      TopicItem(
        topic: Topic(
          id: 'topic-2',
          title: '公告：物品录入要不要写备注',
          isPinned: true,
          isClosed: true,
          user: const User(username: '管理员', email: 'admin@example.com'),
          createdAt: DateTime(2026, 11, 1, 8),
        ),
      ),
    ],
  ),
);

@Preview(name: 'TopicItem 详情', group: previewGroupBoard, size: Size(480, 420))
Widget topicItemDetailPreview() => PreviewFrame(
  width: 480,
  child: TopicItem(
    showBody: true,
    topic: Topic(
      id: 'topic-1',
      title: '阳台储物柜怎么整理比较好？',
      description:
          '柜子有点满，想按使用频率重新分层。\n\n现在常用的都堆在最里面，'
          '每次都要蹲下去掏半天。',
      user: const User(username: '橙子', email: 'chengzi@example.com'),
      createdAt: DateTime(2026, 11, 10, 9, 30),
      editedAt: DateTime(2026, 11, 10, 9, 30),
    ),
  ),
);
