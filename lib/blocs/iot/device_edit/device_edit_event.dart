part of 'device_edit_bloc.dart';

abstract class DeviceEditEvent extends Equatable {
  const DeviceEditEvent();

  @override
  List<Object> get props => [];
}

class DeviceAdded extends DeviceEditEvent {
  final String name;
  final String deviceType;
  final String location;

  const DeviceAdded({
    @required this.name,
    @required this.deviceType,
    @required this.location,
  });

  @override
  List<Object> get props => [name, deviceType, location];

  @override
  String toString() => 'DeviceAdded { name: $name }';
}

class DeviceUpdated extends DeviceEditEvent {
  final String id;
  final String name;
  final String deviceType;
  final String location;

  const DeviceUpdated({
    @required this.id,
    @required this.name,
    @required this.deviceType,
    @required this.location,
  });

  @override
  List<Object> get props => [id, name, deviceType, location];

  @override
  String toString() => 'DeviceUpdated { id: $id }';
}

class DeviceDeleted extends DeviceEditEvent {
  final Device device;

  const DeviceDeleted({@required this.device});

  @override
  List<Object> get props => [device];

  @override
  String toString() => 'DeviceDeleted { name: ${device.name} }';
}

class DeviceSeted extends DeviceEditEvent {
  final String deviceId;
  final String key;
  final String value;
  final String valueType;

  const DeviceSeted({
    @required this.deviceId,
    @required this.key,
    @required this.value,
    @required this.valueType,
  });

  @override
  List<Object> get props => [deviceId];

  @override
  String toString() =>
      'DeviceSeted { id: $deviceId, key: $key, value: $value }';
}
