library push;

import 'package:json_annotation/json_annotation.dart';
import 'package:smart_home/models/user.dart';

part 'push.g.dart';

@JsonSerializable()
class MiPush {
  final User user;
  final String regId;
  final String deviceId;
  final String model;
  final bool enable;

  MiPush({this.user, this.regId, this.enable, this.deviceId, this.model});

  factory MiPush.fromJson(Map<String, dynamic> json) => _$MiPushFromJson(json);

  Map<String, dynamic> toJson() => _$MiPushToJson(this);
}

@JsonSerializable()
class MiPushKey {
  final String appId;
  final String appKey;

  MiPushKey({this.appId, this.appKey});

  factory MiPushKey.fromJson(Map<String, dynamic> json) =>
      _$MiPushKeyFromJson(json);

  Map<String, dynamic> toJson() => _$MiPushKeyToJson(this);
}
