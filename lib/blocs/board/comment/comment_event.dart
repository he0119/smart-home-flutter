part of 'comment_bloc.dart';

abstract class CommentEvent extends Equatable {
  const CommentEvent();

  @override
  List<Object> get props => [];
}

class CommentAdded extends CommentEvent {
  final String topicId;
  final String body;

  const CommentAdded({
    @required this.topicId,
    @required this.body,
  });

  @override
  List<Object> get props => [topicId, body];

  @override
  String toString() => 'CommentAdded { body: $body }';
}

class CommentUpdated extends CommentEvent {
  final String id;
  final String body;

  const CommentUpdated({
    @required this.id,
    @required this.body,
  });

  @override
  List<Object> get props => [id, body];

  @override
  String toString() => 'CommentUpdated { id: $id }';
}

class CommentDeleted extends CommentEvent {
  final Comment comment;

  const CommentDeleted({@required this.comment});

  @override
  List<Object> get props => [comment];

  @override
  String toString() => 'CommentDeleted { id: ${comment.id} }';
}
