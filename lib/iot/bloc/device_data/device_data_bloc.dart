import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/iot/model/iot.dart';
import 'package:smarthome/iot/repository/iot_repository.dart';
import 'package:smarthome/utils/exceptions.dart';

part 'device_data_event.dart';
part 'device_data_state.dart';

class DeviceDataBloc extends Bloc<DeviceDataEvent, DeviceDataState> {
  final IotRepository iotRepository;
  final GraphQLApiClient client;
  final String deviceId;

  StreamSubscription<AutowateringData>? _dataSubscription;
  StreamSubscription<bool>? _connectionSubscription;

  DeviceDataBloc({
    required this.iotRepository,
    required this.deviceId,
    required this.client,
  }) : super(DeviceDataInitial()) {
    on<DeviceDataStarted>(_onDeviceDataStarted);
    on<DeviceDataupdated>(_onDeviceDataupdated);
    on<DeviceDataStoped>(_onDeviceDataStoped);
  }

  @override
  Future<void> close() {
    _dataSubscription?.cancel();
    _connectionSubscription?.cancel();
    return super.close();
  }

  FutureOr<void> _onDeviceDataStarted(
      DeviceDataStarted event, Emitter<DeviceDataState> emit) async {
    emit(DeviceDataInProgress());
    await _dataSubscription?.cancel();
    // 订阅数据
    _dataSubscription =
        iotRepository.autowateringDataStream(deviceId: deviceId).listen(
      (x) async {
        add(DeviceDataupdated(x));
      },
    )..onError(
            (error) {
              if (error is MyException) {
                add(DeviceDataStoped(error.message));
              } else {
                add(const DeviceDataStoped('未知错误'));
              }
            },
          );
    _connectionSubscription = client.websocketConnectionState.listen((state) {
      if (!state) {
        add(const DeviceDataStoped('服务器断开连接'));
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
