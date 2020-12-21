import 'package:flutter/material.dart';

import 'package:smart_home/models/board.dart';

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
        children: [
          for (var comment in comments.take(2))
            Row(
              children: [
                Text(comment.user.username),
                Text(': '),
                Text(comment.body),
              ],
            ),
          if (comments.length >= 2) Text('查看所有评论'),
        ],
      ),
    );
  }
}
