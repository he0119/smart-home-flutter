import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/board/model/board.dart';
import 'package:smarthome/board/providers/comment_edit_provider.dart';
import 'package:smarthome/board/view/comment_edit_page.dart';
import 'package:smarthome/board/view/widgets/item_title.dart';
import 'package:smarthome/app/dimens.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/utils/show_confirm_dialog.dart';
import 'package:smarthome/utils/show_snack_bar.dart';
import 'package:smarthome/widgets/markdown.dart';
import 'package:smarthome/widgets/app_preview.dart';
import 'package:smarthome/widgets/preview_frame.dart';
import 'package:smarthome/user/user.dart';

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
                      final confirmed = await showConfirmDialog(
                        context,
                        title: '删除评论',
                        message: '删除后无法恢复，确认删除这条评论？',
                        confirmLabel: '删除',
                        destructive: true,
                      );
                      if (!confirmed) {
                        return;
                      }
                      showInfoSnackBar('正在删除...', duration: 1);
                      ref
                          .read(commentEditProvider.notifier)
                          .deleteComment(comment);
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
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: MyMarkdownBody(data: comment.body ?? ''),
        ),
      ],
    );
  }
}

/// 开发时在 IDE 里直接看效果，不依赖后端数据。
@AppPreview(name: 'CommentItem', group: previewGroupBoard, size: Size(480, 280))
Widget commentItemPreview() => PreviewFrame(
  width: 480,
  padding: EdgeInsets.zero,
  child: PreviewProviders(
    child: CommentItem(
      comment: Comment(
        id: 'comment-1',
        body: '我按「常用 / 备用 / 一年没动」分了三层，找东西快很多。',
        user: const User(username: '橙子', email: 'chengzi@example.com'),
        createdAt: DateTime(2026, 11, 12, 20),
        editedAt: DateTime(2026, 11, 12, 20),
      ),
      showMenu: true,
    ),
  ),
);
