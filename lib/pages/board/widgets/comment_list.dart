import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:smart_home/models/board.dart';
import 'package:smart_home/utils/gravatar_url.dart';

class CommentList extends StatelessWidget {
  final List<Comment> comments;

  const CommentList({Key key, @required this.comments}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: comments.length,
      itemBuilder: (context, index) {
        return _buildListItem(context, comments[index]);
      },
    );
  }

  Widget _buildListItem(BuildContext context, Comment comment) {
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
                        imageUrl: getGravatarUrl(email: comment.user.email),
                        imageBuilder: (context, imageProvider) => CircleAvatar(
                          backgroundImage: imageProvider,
                        ),
                        placeholder: (context, url) =>
                            CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    )
                  : CircleAvatar(
                      backgroundImage: NetworkImage(
                          getGravatarUrl(email: comment.user.email)),
                    ),
              contentPadding: EdgeInsets.all(0),
              title: Text(comment.user.username),
            ),
            MarkdownBody(data: comment.body),
          ],
        ),
      ),
    );
  }
}
