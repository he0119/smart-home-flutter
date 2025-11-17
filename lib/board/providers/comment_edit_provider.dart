import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/board/model/board.dart';
import 'package:smarthome/board/providers/providers.dart';
import 'package:smarthome/utils/exceptions.dart';

/// Comment edit state
class CommentEditState {
  final CommentEditStatus status;
  final String errorMessage;
  final Comment? comment;

  const CommentEditState({
    this.status = CommentEditStatus.initial,
    this.errorMessage = '',
    this.comment,
  });

  CommentEditState copyWith({
    CommentEditStatus? status,
    String? errorMessage,
    Comment? comment,
  }) {
    return CommentEditState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      comment: comment ?? this.comment,
    );
  }

  @override
  String toString() {
    return 'CommentEditState(status: $status, comment: ${comment?.id})';
  }
}

enum CommentEditStatus {
  initial,
  loading,
  addSuccess,
  updateSuccess,
  deleteSuccess,
  failure,
}

/// Comment edit notifier
class CommentEditNotifier extends Notifier<CommentEditState> {
  @override
  CommentEditState build() {
    return const CommentEditState();
  }

  Future<void> addComment({
    required String topicId,
    required String body,
  }) async {
    state = state.copyWith(status: CommentEditStatus.loading);

    try {
      final boardRepository = ref.read(boardRepositoryProvider);
      final comment = await boardRepository.addComment(
        topicId: topicId,
        body: body,
      );
      state = state.copyWith(
        status: CommentEditStatus.addSuccess,
        comment: comment,
      );
    } on MyException catch (e) {
      state = state.copyWith(
        status: CommentEditStatus.failure,
        errorMessage: e.message,
      );
    }
  }

  Future<void> updateComment({required String id, required String body}) async {
    state = state.copyWith(status: CommentEditStatus.loading);

    try {
      final boardRepository = ref.read(boardRepositoryProvider);
      final comment = await boardRepository.updateComment(id: id, body: body);
      state = state.copyWith(
        status: CommentEditStatus.updateSuccess,
        comment: comment,
      );
    } on MyException catch (e) {
      state = state.copyWith(
        status: CommentEditStatus.failure,
        errorMessage: e.message,
      );
    }
  }

  Future<void> deleteComment(Comment comment) async {
    state = state.copyWith(status: CommentEditStatus.loading);

    try {
      final boardRepository = ref.read(boardRepositoryProvider);
      await boardRepository.deleteComment(commentId: comment.id);
      state = state.copyWith(
        status: CommentEditStatus.deleteSuccess,
        comment: comment,
      );
    } on MyException catch (e) {
      state = state.copyWith(
        status: CommentEditStatus.failure,
        errorMessage: e.message,
      );
    }
  }

  void reset() {
    state = const CommentEditState();
  }
}

/// Comment edit provider
final commentEditProvider =
    NotifierProvider<CommentEditNotifier, CommentEditState>(
      CommentEditNotifier.new,
    );
