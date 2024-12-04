library;

import 'package:json_annotation/json_annotation.dart';
import 'package:smarthome/user/user.dart';

part 'push.g.dart';

@JsonSerializable()
class MiPush {
  final User? user;
  final String? regId;
  final String? deviceId;
  final String? model;
  final bool? enable;

  MiPush({this.user, this.regId, this.enable, this.deviceId, this.model});

  factory MiPush.fromJson(Map<String, dynamic> json) => _$MiPushFromJson(json);

  Map<String, dynamic> toJson() => _$MiPushToJson(this);

  @override
  String toString() {
    return 'MiPush(regId: $regId)';
  }
}

@JsonSerializable()
class MiPushKey {
  final String appId;
  final String appKey;

  MiPushKey({required this.appId, required this.appKey});

  factory MiPushKey.fromJson(Map<String, dynamic> json) =>
      _$MiPushKeyFromJson(json);

  Map<String, dynamic> toJson() => _$MiPushKeyToJson(this);
}
