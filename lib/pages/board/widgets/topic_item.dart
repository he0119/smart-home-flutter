import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:smart_home/models/board.dart';
import 'package:smart_home/pages/board/topic_detail_page.dart';
import 'package:smart_home/pages/board/widgets/item_title.dart';

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
    DateTime recentActive = topic.dateModified;
    if (topic.comments != null &&
        topic.comments.isNotEmpty &&
        recentActive.isBefore(topic.comments.last.dateCreated)) {
      recentActive = topic.comments.last.dateCreated;
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
              dateModified: topic.dateModified,
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
      return InkWell(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ItemTitle(
                user: topic.user,
                dateModified: recentActive,
              ),
              ListTile(title: Text(topic.title)),
            ],
          ),
        ),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => TopicDetailPage(topicId: topic.id)));
        },
      );
    }
  }
}
