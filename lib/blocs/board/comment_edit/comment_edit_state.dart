part of 'comment_edit_bloc.dart';

abstract class CommentEditState extends Equatable {
  const CommentEditState();

  @override
  List<Object> get props => [];
}

class CommentInitial extends CommentEditState {}

class CommentInProgress extends CommentEditState {}

class CommentAddSuccess extends CommentEditState {
  final Comment comment;

  const CommentAddSuccess({@required this.comment});

  @override
  List<Object> get props => [comment];
}

class CommentUpdateSuccess extends CommentEditState {
  final Comment comment;

  const CommentUpdateSuccess({@required this.comment});

  @override
  List<Object> get props => [comment];
}

class CommentDeleteSuccess extends CommentEditState {
  final Comment comment;

  const CommentDeleteSuccess({@required this.comment});

  @override
  List<Object> get props => [comment];
}

class CommentError extends CommentEditState {
  final String message;

  const CommentError({@required this.message});

  @override
  List<Object> get props => [message];

  @override
  String toString() {
    return 'TopicError { $message }';
  }
}
