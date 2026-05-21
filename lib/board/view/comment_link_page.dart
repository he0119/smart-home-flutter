import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/board/providers/topic_detail_provider.dart';
import 'package:smarthome/board/view/topic_detail_page.dart';
import 'package:smarthome/widgets/center_loading_indicator.dart';
import 'package:smarthome/widgets/error_message_button.dart';

class CommentLinkPage extends ConsumerWidget {
  final String commentId;

  const CommentLinkPage({super.key, required this.commentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comment = ref.watch(commentProvider(commentId));

    return comment.when(
      data: (comment) {
        final topicId = comment.topic?.id;
        if (topicId == null || topicId.isEmpty) {
          return Scaffold(
            body: ErrorMessageButton(
              message: '评论没有对应话题',
              onPressed: () => ref.invalidate(commentProvider(commentId)),
            ),
          );
        }
        return TopicDetailPage(topicId: topicId, targetCommentId: comment.id);
      },
      error: (error, stackTrace) => Scaffold(
        body: ErrorMessageButton(
          message: error.toString(),
          onPressed: () => ref.invalidate(commentProvider(commentId)),
        ),
      ),
      loading: () => const Scaffold(body: CenterLoadingIndicator()),
    );
  }
}
