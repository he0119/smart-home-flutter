import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/core/blocs.dart';
import 'package:smart_home/models/board.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/pages/board/widgets/comment_item.dart';

class SliverCommentList extends StatelessWidget {
  final List<Comment> comments;

  const SliverCommentList({
    Key key,
    @required this.comments,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loginUser =
        context.select((AppPreferencesBloc b) => b.state.loginUser);
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return CommentItem(
            comment: comments[index],
            showMenu: loginUser == comments[index].user,
          );
        },
        childCount: comments.length,
      ),
    );
  }
}
