import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smarthome/iot/model/iot.dart';
import 'package:smarthome/iot/repository/iot_repository.dart';
import 'package:smarthome/utils/exceptions.dart';

part 'device_data_event.dart';
part 'device_data_state.dart';

class DeviceDataBloc extends Bloc<DeviceDataEvent, DeviceDataState> {
  final IotRepository iotRepository;
  final String deviceId;

  StreamSubscription<AutowateringData>? _dataSubscription;

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
    // 进入界面后手动获取一次最新数据
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
    await _dataSubscription?.cancel();
    _dataSubscription = iotRepository.deviceDataStream().listen((x) async {
      add(DeviceDataupdated(x));
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
