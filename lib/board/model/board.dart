library board;

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:smarthome/user/user.dart';

part 'board.g.dart';

@JsonSerializable()
class Topic extends Equatable {
  final String id;
  final String? title;
  final String? description;
  final bool? isClosed;
  final bool? isPinned;
  final User? user;
  final DateTime? createdAt;
  final DateTime? editedAt;
  final List<Comment>? comments;

  const Topic({
    required this.id,
    this.title,
    this.description,
    this.isClosed,
    this.isPinned,
    this.user,
    this.createdAt,
    this.editedAt,
    this.comments,
  });

  factory Topic.fromJson(Map<String, dynamic> json) => _$TopicFromJson(json);

  Map<String, dynamic> toJson() => _$TopicToJson(this);

  @override
  List<Object?> get props {
    return [
      id,
      title,
      description,
      isClosed,
      isPinned,
      user,
      createdAt,
      editedAt,
      comments,
    ];
  }

  @override
  String toString() => id;
}

@JsonSerializable()
class Comment extends Equatable {
  final String id;
  final Topic? topic;
  final User? user;
  final String? body;
  final DateTime? createdAt;
  final DateTime? editedAt;
  final Comment? parent;
  final User? replyTo;

  const Comment({
    required this.id,
    this.topic,
    this.user,
    this.body,
    this.createdAt,
    this.editedAt,
    this.parent,
    this.replyTo,
  });

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);

  Map<String, dynamic> toJson() => _$CommentToJson(this);

  @override
  List<Object?> get props {
    return [
      id,
      topic,
      user,
      body,
      createdAt,
      editedAt,
      parent,
      replyTo,
    ];
  }

  @override
  String toString() => id;
}
