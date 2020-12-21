import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:smart_home/models/board.dart';
import 'package:smart_home/pages/board/widgets/item_title.dart';

class CommentItem extends StatelessWidget {
  final Comment comment;

  const CommentItem({Key key, @required this.comment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ItemTitle(
            user: comment.user,
            dateModified: comment.dateModified,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: MarkdownBody(
              data: comment.body,
              selectable: true,
            ),
          ),
          if (comment.children.isNotEmpty) Divider(),
          if (comment.children.isNotEmpty)
            SubCommentList(
              comments: comment.children,
            ),
          Divider(),
        ],
      ),
    );
  }
}

class SubCommentList extends StatelessWidget {
  final List<Comment> comments;

  const SubCommentList({
    Key key,
    @required this.comments,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(32, 8, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: comments.map((e) {
          return Row(
            children: [
              Text(e.user.username),
              Text(': '),
              Text(e.body),
            ],
          );
        }).toList(),
      ),
    );
  }
}
