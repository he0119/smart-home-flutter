// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MiPush _$MiPushFromJson(Map<String, dynamic> json) => MiPush(
  user: json['user'] == null
      ? null
      : User.fromJson(json['user'] as Map<String, dynamic>),
  regId: json['regId'] as String?,
  enable: json['enable'] as bool?,
  deviceId: json['deviceId'] as String?,
  model: json['model'] as String?,
);

Map<String, dynamic> _$MiPushToJson(MiPush instance) => <String, dynamic>{
  'user': instance.user,
  'regId': instance.regId,
  'deviceId': instance.deviceId,
  'model': instance.model,
  'enable': instance.enable,
};

MiPushKey _$MiPushKeyFromJson(Map<String, dynamic> json) =>
    MiPushKey(appId: json['appId'] as String, appKey: json['appKey'] as String);

Map<String, dynamic> _$MiPushKeyToJson(MiPushKey instance) => <String, dynamic>{
  'appId': instance.appId,
  'appKey': instance.appKey,
};
