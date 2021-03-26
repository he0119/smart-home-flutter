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
    required this.title,
    required this.description,
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
    required this.id,
    required this.title,
    required this.description,
  });

  @override
  List<Object> get props => [id, title, description];

  @override
  String toString() => 'TopicUpdated { id: $id }';
}

class TopicDeleted extends TopicEditEvent {
  final Topic topic;

  const TopicDeleted({required this.topic});

  @override
  List<Object> get props => [topic];

  @override
  String toString() => 'TopicDeleted { name: ${topic.title} }';
}

class TopicClosed extends TopicEditEvent {
  final Topic topic;

  const TopicClosed({required this.topic});

  @override
  List<Object> get props => [topic];

  @override
  String toString() => 'TopicClosed { name: ${topic.title} }';
}

class TopicReopened extends TopicEditEvent {
  final Topic topic;

  const TopicReopened({required this.topic});

  @override
  List<Object> get props => [topic];

  @override
  String toString() => 'TopicReopened { name: ${topic.title} }';
}

class TopicPinned extends TopicEditEvent {
  final Topic topic;

  const TopicPinned({required this.topic});

  @override
  List<Object> get props => [topic];

  @override
  String toString() => 'TopicPinned { name: ${topic.title} }';
}

class TopicUnpinned extends TopicEditEvent {
  final Topic topic;

  const TopicUnpinned({required this.topic});

  @override
  List<Object> get props => [topic];

  @override
  String toString() => 'TopicUnpinned { name: ${topic.title} }';
}
