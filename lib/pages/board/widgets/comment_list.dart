import 'package:flutter/material.dart';
import 'package:smart_home/models/board.dart';
import 'package:smart_home/pages/board/widgets/comment_item.dart';

class CommentList extends StatelessWidget {
  final List<Comment> comments;

  const CommentList({Key key, @required this.comments}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      separatorBuilder: (context, index) => Divider(),
      itemCount: comments.length,
      itemBuilder: (context, index) {
        return CommentItem(comment: comments[index]);
      },
    );
  }
}
