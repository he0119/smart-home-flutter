import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:smart_home/models/board.dart';
import 'package:smart_home/repositories/board_repository.dart';

part 'comment_edit_event.dart';
part 'comment_edit_state.dart';

class CommentEditBloc extends Bloc<CommentEditEvent, CommentEditState> {
  final BoardRepository boardRepository;

  CommentEditBloc({@required this.boardRepository}) : super(CommentInitial());

  @override
  Stream<CommentEditState> mapEventToState(
    CommentEditEvent event,
  ) async* {
    if (event is CommentAdded) {
      yield CommentInProgress();
      try {
        Comment comment = await boardRepository.addComment(
          topicId: event.topicId,
          body: event.body,
        );
        yield CommentAddSuccess(comment: comment);
      } catch (e) {
        yield CommentFailure(e.message);
      }
    }
    if (event is CommentUpdated) {
      yield CommentInProgress();
      try {
        Comment comment = await boardRepository.updateComment(
          id: event.id,
          body: event.body,
        );
        yield CommentUpdateSuccess(comment: comment);
      } catch (e) {
        yield CommentFailure(e.message);
      }
    }
    if (event is CommentDeleted) {
      yield CommentInProgress();
      try {
        await boardRepository.deleteComment(commentId: event.comment.id);
        yield CommentDeleteSuccess(comment: event.comment);
      } catch (e) {
        yield CommentFailure(e.message);
      }
    }
  }
}
