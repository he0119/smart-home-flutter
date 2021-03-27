import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthome/app/bloc/blocs.dart';
import 'package:smarthome/board/model/board.dart';
import 'package:smarthome/board/view/widgets/comment_item.dart';

class SliverCommentList extends StatelessWidget {
  final List<Comment> comments;

  const SliverCommentList({
    Key? key,
    required this.comments,
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
