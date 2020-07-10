part of 'topic_bloc.dart';

abstract class TopicEvent extends Equatable {
  const TopicEvent();

  @override
  List<Object> get props => [];
}

class TopicAdded extends TopicEvent {
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

class TopicUpdated extends TopicEvent {
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

class TopicDeleted extends TopicEvent {
  final Topic topic;

  const TopicDeleted({@required this.topic});

  @override
  List<Object> get props => [topic];

  @override
  String toString() => 'TopicDeleted { name: ${topic.title} }';
}
