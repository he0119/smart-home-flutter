import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smarthome/iot/repository/iot_repository.dart';
import 'package:smarthome/iot/model/iot.dart';
import 'package:smarthome/utils/exceptions.dart';

part 'device_edit_event.dart';
part 'device_edit_state.dart';

class DeviceEditBloc extends Bloc<DeviceEditEvent, DeviceEditState> {
  final IotRepository iotRepository;

  DeviceEditBloc({required this.iotRepository}) : super(DeviceEditInitial());

  @override
  Stream<DeviceEditState> mapEventToState(
    DeviceEditEvent event,
  ) async* {
    if (event is DeviceAdded) {
      yield DeviceInProgress();
      try {
        Device device = await iotRepository.addDevice(
          name: event.name,
          deviceType: event.deviceType,
          location: event.location,
        );
        yield DeviceAddSuccess(device: device);
      } on MyException catch (e) {
        yield DeviceFailure(e.message);
      }
    }
    if (event is DeviceUpdated) {
      yield DeviceInProgress();
      try {
        Device device = await iotRepository.updateDevice(
          id: event.id,
          name: event.name,
          deviceType: event.deviceType,
          location: event.location,
        );
        yield DeviceUpdateSuccess(device: device);
      } on MyException catch (e) {
        yield DeviceFailure(e.message);
      }
    }
    if (event is DeviceDeleted) {
      yield DeviceInProgress();
      try {
        await iotRepository.deleteDevice(deviceId: event.device.id);
        yield DeviceDeleteSuccess(device: event.device);
      } on MyException catch (e) {
        yield DeviceFailure(e.message);
      }
    }
    if (event is DeviceSeted) {
      yield DeviceInProgress();
      try {
        Device device = await iotRepository.setDevice(
          id: event.deviceId,
          key: event.key,
          value: event.value,
          valueType: event.valueType,
        );
        yield DeviceSetSuccess(device: device);
      } on MyException catch (e) {
        yield DeviceFailure(e.message);
      }
    }
  }
}
