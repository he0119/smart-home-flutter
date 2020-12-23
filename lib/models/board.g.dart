// GENERATED CODE - DO NOT MODIFY BY HAND

part of board;

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Topic _$TopicFromJson(Map<String, dynamic> json) {
  return Topic(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    isOpen: json['isOpen'] as bool,
    user: json['user'] == null
        ? null
        : User.fromJson(json['user'] as Map<String, dynamic>),
    dateCreated: json['dateCreated'] == null
        ? null
        : DateTime.parse(json['dateCreated'] as String),
    dateModified: json['dateModified'] == null
        ? null
        : DateTime.parse(json['dateModified'] as String),
    comments: (json['comments'] as List)
        ?.map((e) =>
            e == null ? null : Comment.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$TopicToJson(Topic instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'isOpen': instance.isOpen,
      'user': instance.user,
      'dateCreated': instance.dateCreated?.toIso8601String(),
      'dateModified': instance.dateModified?.toIso8601String(),
      'comments': instance.comments,
    };

Comment _$CommentFromJson(Map<String, dynamic> json) {
  return Comment(
    id: json['id'] as String,
    topic: json['topic'] == null
        ? null
        : Topic.fromJson(json['topic'] as Map<String, dynamic>),
    user: json['user'] == null
        ? null
        : User.fromJson(json['user'] as Map<String, dynamic>),
    body: json['body'] as String,
    dateCreated: json['dateCreated'] == null
        ? null
        : DateTime.parse(json['dateCreated'] as String),
    dateModified: json['dateModified'] == null
        ? null
        : DateTime.parse(json['dateModified'] as String),
    parent: json['parent'] == null
        ? null
        : Comment.fromJson(json['parent'] as Map<String, dynamic>),
    replyTo: json['replyTo'] == null
        ? null
        : User.fromJson(json['replyTo'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
      'id': instance.id,
      'topic': instance.topic,
      'user': instance.user,
      'body': instance.body,
      'dateCreated': instance.dateCreated?.toIso8601String(),
      'dateModified': instance.dateModified?.toIso8601String(),
      'parent': instance.parent,
      'replyTo': instance.replyTo,
    };
