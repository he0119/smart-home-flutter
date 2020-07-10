import 'package:flutter/material.dart';
import 'package:smart_home/models/board.dart';
import 'package:smart_home/pages/board/widgets/comment_item.dart';

class SliverCommentList extends StatelessWidget {
  final List<Comment> comments;

  const SliverCommentList({Key key, @required this.comments}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return CommentItem(comment: comments[index]);
        },
        childCount: comments.length,
      ),
    );
  }
}
