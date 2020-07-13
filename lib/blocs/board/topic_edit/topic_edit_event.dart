part of 'topic_edit_bloc.dart';

abstract class TopicEditEvent extends Equatable {
  const TopicEditEvent();

  @override
  List<Object> get props => [];
}

class TopicAdded extends TopicEditEvent {
  final String title;
  final String description;

  const TopicAdded({
    @required this.title,
    @required this.description,
  });

  @override
  List<Object> get props => [title, description];

  @override
  String toString() => 'TopicAdded { title: $title }';
}

class TopicUpdated extends TopicEditEvent {
  final String id;
  final String title;
  final String description;

  const TopicUpdated({
    @required this.id,
    @required this.title,
    @required this.description,
  });

  @override
  List<Object> get props => [id, title, description];

  @override
  String toString() => 'TopicUpdated { id: $id }';
}

class TopicDeleted extends TopicEditEvent {
  final Topic topic;

  const TopicDeleted({@required this.topic});

  @override
  List<Object> get props => [topic];

  @override
  String toString() => 'TopicDeleted { name: ${topic.title} }';
}
