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

  CommentEditBloc({required this.boardRepository}) : super(CommentInitial());

  @override
  Stream<CommentEditState> mapEventToState(
    CommentEditEvent event,
  ) async* {
    if (event is CommentAdded) {
      yield CommentInProgress();
      try {
        final comment = await boardRepository.addComment(
          topicId: event.topicId,
          body: event.body,
        );
        yield CommentAddSuccess(comment: comment);
      } on MyException catch (e) {
        yield CommentFailure(e.message);
      }
    }
    if (event is CommentUpdated) {
      yield CommentInProgress();
      try {
        final comment = await boardRepository.updateComment(
          id: event.id,
          body: event.body,
        );
        yield CommentUpdateSuccess(comment: comment);
      } on MyException catch (e) {
        yield CommentFailure(e.message);
      }
    }
    if (event is CommentDeleted) {
      yield CommentInProgress();
      try {
        await boardRepository.deleteComment(commentId: event.comment.id);
        yield CommentDeleteSuccess(comment: event.comment);
      } on MyException catch (e) {
        yield CommentFailure(e.message);
      }
    }
  }
}
