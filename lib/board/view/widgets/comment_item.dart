import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/board/model/board.dart';
import 'package:smarthome/board/providers/comment_edit_provider.dart';
import 'package:smarthome/board/view/comment_edit_page.dart';
import 'package:smarthome/board/view/widgets/item_title.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/utils/show_snack_bar.dart';
import 'package:smarthome/widgets/markdown.dart';

class CommentItem extends ConsumerWidget {
  final Comment comment;
  final bool showMenu;
  final void Function()? onEdit;

  const CommentItem({
    super.key,
    required this.comment,
    required this.showMenu,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ItemTitle(
          user: comment.user!,
          createdAt: comment.createdAt!,
          editedAt: comment.editedAt!,
          onSelected: showMenu
              ? (Menu menu) async {
                  switch (menu) {
                    case Menu.delete:
                      await showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('删除评论'),
                          content: const Text('你确认要删除该评论？'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('否'),
                            ),
                            TextButton(
                              onPressed: () {
                                showInfoSnackBar('正在删除...', duration: 1);
                                ref
                                    .read(commentEditProvider.notifier)
                                    .deleteComment(comment);
                                Navigator.of(context).pop();
                              },
                              child: const Text('是'),
                            ),
                          ],
                        ),
                      );
                      break;
                    case Menu.edit:
                      final r = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CommentEditPage(
                            isEditing: true,
                            comment: comment,
                          ),
                        ),
                      );
                      if (r == true && onEdit != null) onEdit!();
                      break;
                  }
                }
              : null,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: MyMarkdownBody(data: comment.body!),
        ),
      ],
    );
  }
}
