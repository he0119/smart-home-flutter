import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:smart_home/blocs/board/blocs.dart';

import 'package:smart_home/models/board.dart';
import 'package:smart_home/models/models.dart';
import 'package:smart_home/pages/board/widgets/item_title.dart';
import 'package:smart_home/widgets/show_snack_bar.dart';

class SliverCommentList extends StatelessWidget {
  final List<Comment> comments;

  const SliverCommentList({
    Key key,
    @required this.comments,
  }) : super(key: key);

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

class CommentItem extends StatelessWidget {
  final Comment comment;

  const CommentItem({
    Key key,
    @required this.comment,
  }) : super(key: key);

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
            onSelected: (Menu menu) {
              switch (menu) {
                case Menu.delete:
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('删除评论'),
                      content: Text('你确认要删除该评论？'),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('否'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        FlatButton(
                          child: Text('是'),
                          onPressed: () {
                            showInfoSnackBar('正在删除...', duration: 1);
                            BlocProvider.of<CommentEditBloc>(context)
                                .add(CommentDeleted(comment: comment));
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  );
                  break;
                case Menu.edit:
                  break;
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: MarkdownBody(
              data: comment.body,
              selectable: true,
            ),
          ),
          Divider(),
        ],
      ),
    );
  }
}
