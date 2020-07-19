part of 'device_edit_bloc.dart';

abstract class DeviceEditState extends Equatable {
  const DeviceEditState();

  @override
  List<Object> get props => [];
}

class DeviceEditInitial extends DeviceEditState {}

class DeviceInProgress extends DeviceEditState {}

class DeviceFailure extends DeviceEditState {
  final String message;

  const DeviceFailure(this.message);

  @override
  List<Object> get props => [message];

  @override
  String toString() {
    return 'DeviceFailure { $message }';
  }
}

class DeviceAddSuccess extends DeviceEditState {
  final Device device;

  const DeviceAddSuccess({@required this.device});

  @override
  List<Object> get props => [device];
}

class DeviceUpdateSuccess extends DeviceEditState {
  final Device device;

  const DeviceUpdateSuccess({@required this.device});

  @override
  List<Object> get props => [device];
}

class DeviceDeleteSuccess extends DeviceEditState {
  final Device device;

  const DeviceDeleteSuccess({@required this.device});

  @override
  List<Object> get props => [device];
}

class DeviceSetSuccess extends DeviceEditState {
  final Device device;

  const DeviceSetSuccess({@required this.device});

  @override
  List<Object> get props => [device];
}
