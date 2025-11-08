import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smarthome/board/model/board.dart';
import 'package:smarthome/board/repository/board_repository.dart';
import 'package:smarthome/utils/exceptions.dart';

part 'comment_edit_event.dart';
part 'comment_edit_state.dart';

class CommentEditBloc extends Bloc<CommentEditEvent, CommentEditState> {
  final BoardRepository boardRepository;

  CommentEditBloc({required this.boardRepository}) : super(CommentInitial()) {
    on<CommentAdded>(_onCommentAdded);
    on<CommentUpdated>(_onCommentUpdated);
    on<CommentDeleted>(_onCommentDeleted);
  }

  FutureOr<void> _onCommentAdded(
    CommentAdded event,
    Emitter<CommentEditState> emit,
  ) async {
    emit(CommentInProgress());
    try {
      final comment = await boardRepository.addComment(
        topicId: event.topicId,
        body: event.body,
      );
      emit(CommentAddSuccess(comment: comment));
    } on MyException catch (e) {
      emit(CommentFailure(e.message));
    }
  }

  FutureOr<void> _onCommentUpdated(
    CommentUpdated event,
    Emitter<CommentEditState> emit,
  ) async {
    emit(CommentInProgress());
    try {
      final comment = await boardRepository.updateComment(
        id: event.id,
        body: event.body,
      );
      emit(CommentUpdateSuccess(comment: comment));
    } on MyException catch (e) {
      emit(CommentFailure(e.message));
    }
  }

  FutureOr<void> _onCommentDeleted(
    CommentDeleted event,
    Emitter<CommentEditState> emit,
  ) async {
    emit(CommentInProgress());
    try {
      await boardRepository.deleteComment(commentId: event.comment.id);
      emit(CommentDeleteSuccess(comment: event.comment));
    } on MyException catch (e) {
      emit(CommentFailure(e.message));
    }
  }
}
