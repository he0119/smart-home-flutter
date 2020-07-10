import 'package:flutter/material.dart';
import 'package:smart_home/models/board.dart';
import 'package:smart_home/pages/board/widgets/topic_item.dart';

class TopicList extends StatelessWidget {
  final List<Topic> topics;

  const TopicList({Key key, @required this.topics}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      separatorBuilder: (context, index) => Divider(),
      itemCount: topics.length,
      itemBuilder: (context, index) {
        return TopicItem(topic: topics[index]);
      },
    );
  }
}
