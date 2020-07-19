library iot;

import 'package:json_annotation/json_annotation.dart';

part 'iot.g.dart';

@JsonSerializable()
class Device {
  final String id;
  final String name;
  final String deviceType;
  final String location;
  final DateTime dateCreated;
  final DateTime dateUpdated;
  final bool isOnline;
  final DateTime dateOnline;
  final DateTime dateOffline;

  Device({
    this.id,
    this.name,
    this.deviceType,
    this.location,
    this.dateCreated,
    this.dateUpdated,
    this.isOnline,
    this.dateOnline,
    this.dateOffline,
  });

  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceToJson(this);
}

@JsonSerializable()
class AutowateringData {
  final String id;
  final Device device;
  final DateTime time;
  final double temperature;
  final double humidity;
  final int wifiSignal;
  final bool valve1;
  final bool valve2;
  final bool valve3;
  final bool pump;
  final int valve1Delay;
  final int valve2Delay;
  final int valve3Delay;
  final int pumpDelay;

  AutowateringData({
    this.id,
    this.device,
    this.time,
    this.temperature,
    this.humidity,
    this.wifiSignal,
    this.valve1,
    this.valve2,
    this.valve3,
    this.pump,
    this.valve1Delay,
    this.valve2Delay,
    this.valve3Delay,
    this.pumpDelay,
  });

  factory AutowateringData.fromJson(Map<String, dynamic> json) =>
      _$AutowateringDataFromJson(json);

  Map<String, dynamic> toJson() => _$AutowateringDataToJson(this);
}
