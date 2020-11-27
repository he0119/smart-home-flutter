// GENERATED CODE - DO NOT MODIFY BY HAND

part of push;

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MiPush _$MiPushFromJson(Map<String, dynamic> json) {
  return MiPush(
    user: json['user'] == null
        ? null
        : User.fromJson(json['user'] as Map<String, dynamic>),
    regId: json['regId'] as String,
    enable: json['enable'] as bool,
  );
}

Map<String, dynamic> _$MiPushToJson(MiPush instance) => <String, dynamic>{
      'user': instance.user,
      'regId': instance.regId,
      'enable': instance.enable,
    };

MiPushKey _$MiPushKeyFromJson(Map<String, dynamic> json) {
  return MiPushKey(
    appId: json['appId'] as String,
    appKey: json['appKey'] as String,
  );
}

Map<String, dynamic> _$MiPushKeyToJson(MiPushKey instance) => <String, dynamic>{
      'appId': instance.appId,
      'appKey': instance.appKey,
    };
