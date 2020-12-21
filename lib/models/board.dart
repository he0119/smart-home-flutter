library board;

import 'package:json_annotation/json_annotation.dart';

import 'package:smart_home/models/user.dart';

part 'board.g.dart';

@JsonSerializable()
class Topic {
  final String id;
  final String title;
  final String description;
  final bool isOpen;
  final User user;
  final DateTime dateCreated;
  final DateTime dateModified;

  Topic({
    this.id,
    this.title,
    this.description,
    this.isOpen,
    this.user,
    this.dateCreated,
    this.dateModified,
  });

  factory Topic.fromJson(Map<String, dynamic> json) => _$TopicFromJson(json);

  Map<String, dynamic> toJson() => _$TopicToJson(this);
}

@JsonSerializable()
class Comment {
  final String id;
  final Topic topic;
  final User user;
  final String body;
  final DateTime dateCreated;
  final DateTime dateModified;
  final Comment parent;
  final User replyTo;
  final List<Comment> children;

  Comment({
    this.id,
    this.topic,
    this.user,
    this.body,
    this.dateCreated,
    this.dateModified,
    this.parent,
    this.replyTo,
    this.children,
  });

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);

  Map<String, dynamic> toJson() => _$CommentToJson(this);
}
