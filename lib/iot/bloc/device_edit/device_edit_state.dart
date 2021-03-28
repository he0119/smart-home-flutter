part of 'device_edit_bloc.dart';

abstract class DeviceEditState extends Equatable {
  const DeviceEditState();

  @override
  List<Object?> get props => [];
}

class DeviceEditInitial extends DeviceEditState {
  @override
  String toString() => 'DeviceEditInitial';
}

class DeviceInProgress extends DeviceEditState {
  @override
  String toString() => 'DeviceInProgress';
}

class DeviceFailure extends DeviceEditState {
  final String message;

  const DeviceFailure(this.message);

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'DeviceFailure(message: $message)';
}

class DeviceAddSuccess extends DeviceEditState {
  final Device device;

  const DeviceAddSuccess({required this.device});

  @override
  List<Object> get props => [device];

  @override
  String toString() => 'DeviceAddSuccess(device: $device)';
}

class DeviceUpdateSuccess extends DeviceEditState {
  final Device device;

  const DeviceUpdateSuccess({required this.device});

  @override
  List<Object> get props => [device];

  @override
  String toString() => 'DeviceUpdateSuccess(device: $device)';
}

class DeviceDeleteSuccess extends DeviceEditState {
  final Device device;

  const DeviceDeleteSuccess({required this.device});

  @override
  List<Object> get props => [device];

  @override
  String toString() => 'DeviceDeleteSuccess(device: $device)';
}

class DeviceSetSuccess extends DeviceEditState {
  final Device device;

  const DeviceSetSuccess({required this.device});

  @override
  List<Object> get props => [device];

  @override
  String toString() => 'DeviceSetSuccess(device: $device)';
}
