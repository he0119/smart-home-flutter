import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smarthome/iot/repository/iot_repository.dart';
import 'package:smarthome/iot/model/iot.dart';
import 'package:smarthome/utils/exceptions.dart';

part 'device_data_event.dart';
part 'device_data_state.dart';

Stream<int> timedCounter(int interval) async* {
  var i = 0;
  while (true) {
    yield i++;
    await Future.delayed(Duration(seconds: interval));
  }
}

class DeviceDataBloc extends Bloc<DeviceDataEvent, DeviceDataState> {
  final IotRepository iotRepository;
  final String deviceId;

  StreamSubscription<int>? _dataSubscription;

  DeviceDataBloc({
    required this.iotRepository,
    required this.deviceId,
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
    await _dataSubscription?.cancel();
    yield DeviceDataFailure(event.message);
  }

  Stream<DeviceDataState> _mapDeviceDataStartedToState(
      DeviceDataStarted event) async* {
    yield DeviceDataInProgress();
    await _dataSubscription?.cancel();
    _dataSubscription = timedCounter(event.refreshInterval).listen((x) async {
      try {
        final data =
            await iotRepository.autowateringData(deviceId: deviceId, number: 1);
        add(DeviceDataupdated(data[0]));
      } on MyException catch (e) {
        add(DeviceDataStoped(e.message));
      }
    });
  }
}
