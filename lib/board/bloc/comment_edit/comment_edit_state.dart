part of 'comment_edit_bloc.dart';

abstract class CommentEditState extends Equatable {
  const CommentEditState();

  @override
  List<Object?> get props => [];
}

class CommentInitial extends CommentEditState {
  @override
  String toString() => 'CommentInitial';
}

class CommentInProgress extends CommentEditState {
  @override
  String toString() => 'CommentInProgress';
}

class CommentFailure extends CommentEditState {
  final String message;

  const CommentFailure(this.message);

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'CommentFailure(message: $message)';
}

class CommentAddSuccess extends CommentEditState {
  final Comment comment;

  const CommentAddSuccess({required this.comment});

  @override
  List<Object> get props => [comment];

  @override
  String toString() => 'CommentAddSuccess(comment: $comment)';
}

class CommentUpdateSuccess extends CommentEditState {
  final Comment comment;

  const CommentUpdateSuccess({required this.comment});

  @override
  List<Object> get props => [comment];

  @override
  String toString() => 'CommentUpdateSuccess(comment: $comment)';
}

class CommentDeleteSuccess extends CommentEditState {
  final Comment comment;

  const CommentDeleteSuccess({required this.comment});

  @override
  List<Object> get props => [comment];

  @override
  String toString() => 'CommentDeleteSuccess(comment: $comment)';
}
