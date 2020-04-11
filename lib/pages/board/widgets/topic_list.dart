import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:smart_home/models/board.dart';
import 'package:smart_home/pages/board/topic_detail_page.dart';
import 'package:smart_home/utils/gravatar_url.dart';

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
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListTile(
              leading: !kIsWeb
                  ? CircleAvatar(
                      child: CachedNetworkImage(
                        imageUrl: getGravatarUrl(email: topic.user.email),
                        imageBuilder: (context, imageProvider) => CircleAvatar(
                          backgroundImage: imageProvider,
                        ),
                        placeholder: (context, url) =>
                            CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    )
                  : CircleAvatar(
                      backgroundImage:
                          NetworkImage(getGravatarUrl(email: topic.user.email)),
                    ),
              contentPadding: EdgeInsets.all(0),
              title: Text(topic.user.username),
              onTap: () {
                Navigator.of(context).pushNamed(
                  TopicDetailPage.routeName,
                  arguments: topic.id,
                );
              },
            ),
            Text(topic.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                )),
            MarkdownBody(data: topic.description),
          ],
        ),
      ),
    );
  }
}
