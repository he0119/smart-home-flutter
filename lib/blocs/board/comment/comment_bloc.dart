import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:smart_home/models/board.dart';
import 'package:smart_home/repositories/board_repository.dart';
import 'package:smart_home/repositories/graphql_api_client.dart';

part 'comment_event.dart';
part 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final BoardRepository boardRepository;

  CommentBloc({@required this.boardRepository}) : super(CommentInitial());

  @override
  Stream<CommentState> mapEventToState(
    CommentEvent event,
  ) async* {
    if (event is CommentAdded) {
      yield CommentInProgress();
      try {
        Comment comment = await boardRepository.addComment(
          topicId: event.topicId,
          body: event.body,
        );
        yield CommentAddSuccess(comment: comment);
      } on GraphQLApiException catch (e) {
        yield CommentError(message: e.message);
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
      } on GraphQLApiException catch (e) {
        yield CommentError(message: e.message);
      }
    }
    if (event is CommentDeleted) {
      yield CommentInProgress();
      try {
        await boardRepository.deleteComment(commentId: event.comment.id);
        yield CommentDeleteSuccess(comment: event.comment);
      } on GraphQLApiException catch (e) {
        yield CommentError(message: e.message);
      }
    }
  }
}
