// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Session _$SessionFromJson(Map<String, dynamic> json) => Session(
  id: json['id'] as String,
  ip: json['ip'] as String,
  isCurrent: json['isCurrent'] as bool,
  isValid: json['isValid'] as bool,
  lastActivity: DateTime.parse(json['lastActivity'] as String),
  userAgent: json['userAgent'] as String,
);

Map<String, dynamic> _$SessionToJson(Session instance) => <String, dynamic>{
  'id': instance.id,
  'ip': instance.ip,
  'isCurrent': instance.isCurrent,
  'isValid': instance.isValid,
  'lastActivity': instance.lastActivity.toIso8601String(),
  'userAgent': instance.userAgent,
};

User _$UserFromJson(Map<String, dynamic> json) => User(
  username: json['username'] as String,
  email: json['email'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'username': instance.username,
  'email': instance.email,
  'avatarUrl': instance.avatarUrl,
};
