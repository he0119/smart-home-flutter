part of 'comment_bloc.dart';

abstract class CommentState extends Equatable {
  const CommentState();

  @override
  List<Object> get props => [];
}

class CommentInitial extends CommentState {}

class CommentInProgress extends CommentState {}

class CommentAddSuccess extends CommentState {
  final Comment comment;

  const CommentAddSuccess({@required this.comment});

  @override
  List<Object> get props => [comment];
}

class CommentUpdateSuccess extends CommentState {
  final Comment comment;

  const CommentUpdateSuccess({@required this.comment});

  @override
  List<Object> get props => [comment];
}

class CommentDeleteSuccess extends CommentState {
  final Comment comment;

  const CommentDeleteSuccess({@required this.comment});

  @override
  List<Object> get props => [comment];
}

class CommentError extends CommentState {
  final String message;

  const CommentError({@required this.message});

  @override
  List<Object> get props => [message];

  @override
  String toString() {
    return 'TopicError { $message }';
  }
}
