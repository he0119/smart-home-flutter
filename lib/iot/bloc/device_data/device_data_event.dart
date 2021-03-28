part of 'device_data_bloc.dart';

abstract class DeviceDataEvent extends Equatable {
  const DeviceDataEvent();

  @override
  List<Object?> get props => [];
}

class DeviceDataStarted extends DeviceDataEvent {
  final int refreshInterval;

  const DeviceDataStarted(this.refreshInterval);

  @override
  String toString() => 'DeviceDataStarted(refreshInterval: $refreshInterval)';
}

class DeviceDataStoped extends DeviceDataEvent {
  final String message;

  const DeviceDataStoped(this.message);

  @override
  List<Object> get props => [message];

  @override
  String toString() => 'DeviceDataStoped(message: $message)';
}

class DeviceDataupdated extends DeviceDataEvent {
  final AutowateringData autowateringData;

  const DeviceDataupdated(this.autowateringData);

  @override
  List<Object> get props => [autowateringData];

  @override
  String toString() => 'DeviceDataupdated(autowateringData: $autowateringData)';
}
