part of 'device_data_bloc.dart';

abstract class DeviceDataState extends Equatable {
  const DeviceDataState();

  @override
  List<Object?> get props => [];
}

class DeviceDataInitial extends DeviceDataState {
  @override
  String toString() => 'DeviceDataInitial';
}

class DeviceDataInProgress extends DeviceDataState {
  @override
  String toString() => 'DeviceDataInProgress';
}

class DeviceDataSuccess extends DeviceDataState {
  final AutowateringData autowateringData;

  const DeviceDataSuccess(this.autowateringData);

  @override
  List<Object?> get props => [
        autowateringData.time,
        autowateringData.device!.isOnline,
      ];

  @override
  String toString() => 'DeviceDataSuccess(autowateringData: $autowateringData)';
}

class DeviceDataFailure extends DeviceDataState {
  final String message;

  const DeviceDataFailure(this.message);

  @override
  List<Object> get props => [message];

  @override
  String toString() => 'DeviceDataFailure(message: $message)';
}
