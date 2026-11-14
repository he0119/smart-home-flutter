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
        if (topic.isClosed!)
          Icon(Icons.lock_outline, size: 16, color: colors.onSurfaceVariant),
        if (topic.isPinned!)
          Icon(
            Icons.push_pin_outlined,
            size: 16,
            color: colors.onSurfaceVariant,
          ),
      ];
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
            ListTile(
              title: Row(
                children: <Widget>[
                  if (flags.isNotEmpty) ...<Widget>[
                    ...flags,
                    const SizedBox(width: 6),
                  ],
                  Expanded(child: Text(topic.title!)),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
