import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smart_home/models/iot.dart';
import 'package:smart_home/repositories/iot_repository.dart';

part 'device_data_event.dart';
part 'device_data_state.dart';

class Ticker {
  Stream<int> tick(int deration) {
    return Stream.periodic(Duration(seconds: deration), (x) => x);
  }
}

class DeviceDataBloc extends Bloc<DeviceDataEvent, DeviceDataState> {
  final IotRepository iotRepository;

  final Ticker _ticker = Ticker();
  StreamSubscription<int> _dataSubscription;

  DeviceDataBloc({this.iotRepository}) : super(DeviceDataInitial());

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
  }

  Stream<DeviceDataState> _mapDeviceDataStartedToState(
      DeviceDataStarted event) async* {
    yield DeviceDataInProgress();
    _dataSubscription?.cancel();
    _dataSubscription = _ticker.tick(10).listen((x) async {
      List<AutowateringData> data =
          await iotRepository.deviceData(deviceId: '1', number: 1);
      add(DeviceDataupdated(data[0]));
    });
  }
}
