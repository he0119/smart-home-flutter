import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:smarthome/models/iot.dart';
import 'package:smarthome/repositories/iot_repository.dart';

part 'device_data_event.dart';
part 'device_data_state.dart';

Stream<int> timedCounter(int interval) async* {
  int i = 0;
  while (true) {
    yield i++;
    await Future.delayed(Duration(seconds: interval));
  }
}

class DeviceDataBloc extends Bloc<DeviceDataEvent, DeviceDataState> {
  final IotRepository iotRepository;
  final String deviceId;

  StreamSubscription<int> _dataSubscription;

  DeviceDataBloc({
    @required this.iotRepository,
    @required this.deviceId,
  }) : super(DeviceDataInitial());

  @override
  Future<void> close() {
    _dataSubscription?.cancel();
    return super.close();
  }

  @override
  Stream<DeviceDataState> mapEventToState(
    DeviceDataEvent event,
  ) async* {
    if (event is DeviceDataStarted) {
      yield* _mapDeviceDataStartedToState(event);
    } else if (event is DeviceDataupdated) {
      yield* _mapDeviceDataupdatedToState(event);
    } else if (event is DeviceDataStoped) {
      yield* _mapDeviceDataStopedToState(event);
    }
  }

  Stream<DeviceDataState> _mapDeviceDataupdatedToState(
      DeviceDataupdated event) async* {
    yield DeviceDataSuccess(event.autowateringData);
  }

  Stream<DeviceDataState> _mapDeviceDataStopedToState(
      DeviceDataStoped event) async* {
    _dataSubscription?.cancel();
    yield DeviceDataFailure(event.message);
  }

  Stream<DeviceDataState> _mapDeviceDataStartedToState(
      DeviceDataStarted event) async* {
    yield DeviceDataInProgress();
    _dataSubscription?.cancel();
    _dataSubscription = timedCounter(event.refreshInterval).listen((x) async {
      try {
        List<AutowateringData> data =
            await iotRepository.autowateringData(deviceId: deviceId, number: 1);
        add(DeviceDataupdated(data[0]));
      } catch (e) {
        add(DeviceDataStoped(e.message));
      }
    });
  }
}
