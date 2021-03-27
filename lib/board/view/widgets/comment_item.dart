import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:smarthome/board/bloc/blocs.dart';
import 'package:smarthome/board/model/board.dart';
import 'package:smarthome/board/view/comment_edit_page.dart';
import 'package:smarthome/board/view/widgets/item_title.dart';
import 'package:smarthome/board/repository/board_repository.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/utils/show_snack_bar.dart';

class CommentItem extends StatelessWidget {
  final Comment comment;
  final bool showMenu;

  const CommentItem({
    Key? key,
    required this.comment,
    required this.showMenu,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final descending =
        context.select((AppPreferencesBloc b) => b.state.commentDescending);
    return Container(
      key: ValueKey(comment.id),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ItemTitle(
            user: comment.user,
            editedAt: comment.editedAt,
            onSelected: showMenu
                ? (Menu menu) async {
                    switch (menu) {
                      case Menu.delete:
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text('删除评论'),
                            content: Text('你确认要删除该评论？'),
                            actions: <Widget>[
                              TextButton(
                                child: Text('否'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
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
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider(
                              create: (context) => CommentEditBloc(
                                  boardRepository:
                                      RepositoryProvider.of<BoardRepository>(
                                          context)),
                              child: CommentEditPage(
                                isEditing: true,
                                comment: comment,
                              ),
                            ),
                          ),
                        );
                        BlocProvider.of<TopicDetailBloc>(context)
                            .add(TopicDetailFetched(
                          descending: descending,
                          cache: false,
                        ));
                        break;
                    }
                  }
                : null,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: MarkdownBody(
              data: comment.body!,
              selectable: true,
            ),
          ),
        ],
      ),
    );
  }
}
