// GENERATED CODE - DO NOT MODIFY BY HAND

part of iot;

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Device _$DeviceFromJson(Map<String, dynamic> json) => Device(
      id: json['id'] as String,
      name: json['name'] as String,
      deviceType: json['deviceType'] as String?,
      location: json['location'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      editedAt: json['editedAt'] == null
          ? null
          : DateTime.parse(json['editedAt'] as String),
      isOnline: json['isOnline'] as bool?,
      onlineAt: json['onlineAt'] == null
          ? null
          : DateTime.parse(json['onlineAt'] as String),
      offlineAt: json['offlineAt'] == null
          ? null
          : DateTime.parse(json['offlineAt'] as String),
    );

Map<String, dynamic> _$DeviceToJson(Device instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'deviceType': instance.deviceType,
      'location': instance.location,
      'createdAt': instance.createdAt?.toIso8601String(),
      'editedAt': instance.editedAt?.toIso8601String(),
      'isOnline': instance.isOnline,
      'onlineAt': instance.onlineAt?.toIso8601String(),
      'offlineAt': instance.offlineAt?.toIso8601String(),
    };

AutowateringData _$AutowateringDataFromJson(Map<String, dynamic> json) =>
    AutowateringData(
      id: json['id'] as String?,
      device: json['device'] == null
          ? null
          : Device.fromJson(json['device'] as Map<String, dynamic>),
      time:
          json['time'] == null ? null : DateTime.parse(json['time'] as String),
      temperature: (json['temperature'] as num?)?.toDouble(),
      humidity: (json['humidity'] as num?)?.toDouble(),
      wifiSignal: json['wifiSignal'] as int?,
      valve1: json['valve1'] as bool?,
      valve2: json['valve2'] as bool?,
      valve3: json['valve3'] as bool?,
      pump: json['pump'] as bool?,
      valve1Delay: json['valve1Delay'] as int?,
      valve2Delay: json['valve2Delay'] as int?,
      valve3Delay: json['valve3Delay'] as int?,
      pumpDelay: json['pumpDelay'] as int?,
    );

Map<String, dynamic> _$AutowateringDataToJson(AutowateringData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'device': instance.device,
      'time': instance.time?.toIso8601String(),
      'temperature': instance.temperature,
      'humidity': instance.humidity,
      'wifiSignal': instance.wifiSignal,
      'valve1': instance.valve1,
      'valve2': instance.valve2,
      'valve3': instance.valve3,
      'pump': instance.pump,
      'valve1Delay': instance.valve1Delay,
      'valve2Delay': instance.valve2Delay,
      'valve3Delay': instance.valve3Delay,
      'pumpDelay': instance.pumpDelay,
    };
