import 'package:material_ui/material_ui.dart';
import 'package:smarthome/board/model/board.dart';

import 'package:smarthome/board/view/widgets/item_title.dart';
import 'package:smarthome/core/router/router_extensions.dart';
import 'package:smarthome/widgets/markdown.dart';

class TopicItem extends StatelessWidget {
  final Topic topic;
  final bool showBody;

  const TopicItem({super.key, required this.topic, this.showBody = false});

  @override
  Widget build(BuildContext context) {
    // 获取最近互动时间
    var activeAt = topic.editedAt;
    if (topic.comments != null &&
        topic.comments!.isNotEmpty &&
        activeAt!.isBefore(topic.comments!.last.createdAt!)) {
      activeAt = topic.comments!.last.createdAt;
    }
    if (showBody) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              topic.title!,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
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
      var title = topic.title!;
      if (topic.isClosed!) title = '🔒$title';
      if (topic.isPinned!) title = '🔝$title';
      return InkWell(
        onTap: () async {
          context.goTopicDetail(topic.id);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ItemTitle(
              user: topic.user!,
              createdAt: activeAt!,
              editedAt: activeAt,
            ),
            ListTile(title: Text(title)),
          ],
        ),
      );
    }
  }
}
