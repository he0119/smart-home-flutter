part of 'device_data_bloc.dart';

abstract class DeviceDataState extends Equatable {
  const DeviceDataState();

  @override
  List<Object> get props => [];
}

class DeviceDataInitial extends DeviceDataState {}

class DeviceDataInProgress extends DeviceDataState {}

class DeviceDataSuccess extends DeviceDataState {
  final AutowateringData autowateringData;

  const DeviceDataSuccess(this.autowateringData);

  @override
  List<Object> get props => [autowateringData.time];

  @override
  String toString() => 'DeviceDataSuccess { time ${autowateringData.time} }';
}
