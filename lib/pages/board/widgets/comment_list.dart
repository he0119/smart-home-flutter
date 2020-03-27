import 'package:flutter/material.dart';
import 'package:smart_home/models/board.dart';

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
    return Card(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
        child: Text(comment.body),
      ),
    );
  }
}
