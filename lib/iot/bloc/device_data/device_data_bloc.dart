import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smarthome/iot/model/iot.dart';
import 'package:smarthome/iot/repository/iot_repository.dart';
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
  }) : super(DeviceDataInitial()) {
    on<DeviceDataStarted>(_onDeviceDataStarted);
    on<DeviceDataupdated>(_onDeviceDataupdated);
    on<DeviceDataStoped>(_onDeviceDataStoped);
  }

  @override
  Future<void> close() {
    _dataSubscription?.cancel();
    return super.close();
  }

  FutureOr<void> _onDeviceDataStarted(
      DeviceDataStarted event, Emitter<DeviceDataState> emit) async {
    emit(DeviceDataInProgress());
    await _dataSubscription?.cancel();
    _dataSubscription = timedCounter(event.refreshInterval).listen((x) async {
      try {
        final data =
            await iotRepository.autowateringData(deviceId: deviceId, number: 1);
        if (data.isNotEmpty) {
          add(DeviceDataupdated(data.first));
        } else {
          add(const DeviceDataStoped('无数据'));
        }
      } on MyException catch (e) {
        add(DeviceDataStoped(e.message));
      }
    });
  }

  FutureOr<void> _onDeviceDataupdated(
      DeviceDataupdated event, Emitter<DeviceDataState> emit) async {
    emit(DeviceDataSuccess(event.autowateringData));
  }

  FutureOr<void> _onDeviceDataStoped(
      DeviceDataStoped event, Emitter<DeviceDataState> emit) async {
    await _dataSubscription?.cancel();
    emit(DeviceDataFailure(event.message));
  }
}
