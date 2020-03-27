import 'package:flutter/material.dart';
import 'package:smart_home/models/board.dart';
import 'package:smart_home/pages/board/topic_detail_page.dart';

class TopicList extends StatelessWidget {
  final List<Topic> topics;

  const TopicList({Key key, @required this.topics}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: topics.length,
      itemBuilder: (context, index) {
        return _buildListItem(context, topics[index]);
      },
    );
  }

  Widget _buildListItem(BuildContext context, Topic topic) {
    return Card(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
        child: ListTile(
          title: Text(topic.title),
          subtitle: Text(topic.description),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => TopicDetailPage(topicId: topic.id),
            ));
          },
        ),
      ),
    );
  }
}
