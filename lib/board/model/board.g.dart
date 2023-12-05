// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'board.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Topic _$TopicFromJson(Map<String, dynamic> json) => Topic(
      id: json['id'] as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
      isClosed: json['isClosed'] as bool?,
      isPinned: json['isPinned'] as bool?,
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      editedAt: json['editedAt'] == null
          ? null
          : DateTime.parse(json['editedAt'] as String),
      comments: (json['comments'] as List<dynamic>?)
          ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TopicToJson(Topic instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'isClosed': instance.isClosed,
      'isPinned': instance.isPinned,
      'user': instance.user,
      'createdAt': instance.createdAt?.toIso8601String(),
      'editedAt': instance.editedAt?.toIso8601String(),
      'comments': instance.comments,
    };

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
      id: json['id'] as String,
      topic: json['topic'] == null
          ? null
          : Topic.fromJson(json['topic'] as Map<String, dynamic>),
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      body: json['body'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      editedAt: json['editedAt'] == null
          ? null
          : DateTime.parse(json['editedAt'] as String),
      parent: json['parent'] == null
          ? null
          : Comment.fromJson(json['parent'] as Map<String, dynamic>),
      replyTo: json['replyTo'] == null
          ? null
          : User.fromJson(json['replyTo'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
      'id': instance.id,
      'topic': instance.topic,
      'user': instance.user,
      'body': instance.body,
      'createdAt': instance.createdAt?.toIso8601String(),
      'editedAt': instance.editedAt?.toIso8601String(),
      'parent': instance.parent,
      'replyTo': instance.replyTo,
    };
