import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smarthome/iot/model/iot.dart';
import 'package:smarthome/iot/repository/iot_repository.dart';
import 'package:smarthome/utils/exceptions.dart';

part 'device_edit_event.dart';
part 'device_edit_state.dart';

class DeviceEditBloc extends Bloc<DeviceEditEvent, DeviceEditState> {
  final IotRepository iotRepository;

  DeviceEditBloc({required this.iotRepository}) : super(DeviceEditInitial()) {
    on<DeviceAdded>(_onDeviceAdded);
    on<DeviceUpdated>(_onDeviceUpdated);
    on<DeviceDeleted>(_onDeviceDeleted);
    on<DeviceSeted>(_onDeviceSeted);
  }

  FutureOr<void> _onDeviceAdded(
      DeviceAdded event, Emitter<DeviceEditState> emit) async {
    emit(DeviceInProgress());
    try {
      final device = await iotRepository.addDevice(
        name: event.name,
        deviceType: event.deviceType,
        location: event.location,
      );
      emit(DeviceAddSuccess(device: device));
    } on MyException catch (e) {
      emit(DeviceFailure(e.message));
    }
  }

  FutureOr<void> _onDeviceUpdated(
      DeviceUpdated event, Emitter<DeviceEditState> emit) async {
    emit(DeviceInProgress());
    try {
      final device = await iotRepository.updateDevice(
        id: event.id,
        name: event.name,
        deviceType: event.deviceType,
        location: event.location,
      );
      emit(DeviceUpdateSuccess(device: device));
    } on MyException catch (e) {
      emit(DeviceFailure(e.message));
    }
  }

  FutureOr<void> _onDeviceDeleted(
      DeviceDeleted event, Emitter<DeviceEditState> emit) async {
    emit(DeviceInProgress());
    try {
      await iotRepository.deleteDevice(deviceId: event.device.id);
      emit(DeviceDeleteSuccess(device: event.device));
    } on MyException catch (e) {
      emit(DeviceFailure(e.message));
    }
  }

  FutureOr<void> _onDeviceSeted(
      DeviceSeted event, Emitter<DeviceEditState> emit) async {
    emit(DeviceInProgress());
    try {
      final device = await iotRepository.setDevice(
        id: event.deviceId,
        key: event.key,
        value: event.value,
        valueType: event.valueType,
      );
      emit(DeviceSetSuccess(device: device));
    } on MyException catch (e) {
      emit(DeviceFailure(e.message));
    }
  }
}
