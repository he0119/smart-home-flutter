import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:smart_home/models/board.dart';
import 'package:smart_home/pages/board/topic_detail_page.dart';
import 'package:smart_home/pages/board/widgets/item_title.dart';
import 'package:smart_home/routers/delegate.dart';

class TopicItem extends StatelessWidget {
  final Topic topic;
  final bool showBody;

  const TopicItem({
    Key key,
    @required this.topic,
    this.showBody = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 获取最近互动时间
    DateTime activeAt = topic.editedAt;
    if (topic.comments != null &&
        topic.comments.isNotEmpty &&
        activeAt.isBefore(topic.comments.last.createdAt)) {
      activeAt = topic.comments.last.createdAt;
    }
    if (showBody) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: SelectableText(
                topic.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
            ),
            ItemTitle(
              user: topic.user,
              editedAt: topic.editedAt,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: MarkdownBody(
                data: topic.description,
                selectable: true,
              ),
            ),
            Divider(),
          ],
        ),
      );
    } else {
      // 依据话题添加标志
      String title = topic.title;
      if (!topic.isOpen) title = '🔒' + title;
      if (topic.isPin) title = '🔝' + title;
      return InkWell(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ItemTitle(
                user: topic.user,
                editedAt: activeAt,
              ),
              ListTile(title: Text(title)),
            ],
          ),
        ),
        onTap: () async {
          MyRouterDelegate.of(context).push(TopicDetailPage(topicId: topic.id));
        },
      );
    }
  }
}
