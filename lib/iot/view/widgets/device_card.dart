import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthome/iot/bloc/blocs.dart';
import 'package:smarthome/iot/repository/iot_repository.dart';
import 'package:smarthome/utils/date_format_extension.dart';
import 'package:smarthome/utils/show_snack_bar.dart';

class DeviceCard extends StatelessWidget {
  final String deviceId;

  const DeviceCard({Key? key, required this.deviceId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DeviceDataBloc>(
          create: (_) => DeviceDataBloc(
            iotRepository: RepositoryProvider.of<IotRepository>(context),
            deviceId: deviceId,
          )..add(const DeviceDataStarted()),
        ),
        BlocProvider<DeviceEditBloc>(
          create: (_) => DeviceEditBloc(
            iotRepository: RepositoryProvider.of<IotRepository>(context),
          ),
        ),
      ],
      child: const DeviceCardChild(),
    );
  }
}

class DeviceCardChild extends StatelessWidget {
  const DeviceCardChild({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceDataBloc, DeviceDataState>(
      builder: (context, state) {
        if (state is DeviceDataSuccess) {
          final device = state.autowateringData.device;
          final data = state.autowateringData;
          return Card(
            child: Column(children: [
              ListTile(
                title: Text(device!.name),
                subtitle: Text(data.time!.toLocalStr()),
                trailing: Text(device.isOnline! ? '在线' : '离线'),
              ),
              ListTile(title: Text('温度：${data.temperature}')),
              ListTile(title: Text('湿度：${data.humidity}')),
              SwitchListTile(
                title: const Text('树木'),
                value: data.valve1!,
                onChanged: (value) {
                  BlocProvider.of<DeviceEditBloc>(context).add(DeviceSeted(
                    deviceId: device.id,
                    key: 'valve1',
                    value: value.toString(),
                    valueType: 'BOOLEAN',
                  ));
                  showInfoSnackBar(value ? '正在开启...' : '正在关闭...');
                },
              ),
              SwitchListTile(
                title: const Text('菜地'),
                value: data.valve2!,
                onChanged: (value) {
                  BlocProvider.of<DeviceEditBloc>(context).add(DeviceSeted(
                    deviceId: device.id,
                    key: 'valve2',
                    value: value.toString(),
                    valueType: 'BOOLEAN',
                  ));
                  showInfoSnackBar(value ? '正在开启...' : '正在关闭...');
                },
              ),
              SwitchListTile(
                title: const Text('后花园'),
                value: data.valve3!,
                onChanged: (value) {
                  BlocProvider.of<DeviceEditBloc>(context).add(DeviceSeted(
                    deviceId: device.id,
                    key: 'valve3',
                    value: value.toString(),
                    valueType: 'BOOLEAN',
                  ));
                  showInfoSnackBar(value ? '正在开启...' : '正在关闭...');
                },
              ),
              SwitchListTile(
                title: const Text('水泵'),
                value: data.pump!,
                onChanged: (value) {
                  BlocProvider.of<DeviceEditBloc>(context).add(DeviceSeted(
                    deviceId: device.id,
                    key: 'pump',
                    value: value.toString(),
                    valueType: 'BOOLEAN',
                  ));
                  showInfoSnackBar(value ? '正在开启...' : '正在关闭...');
                },
              ),
              ListTile(title: Text('无线信号强度：${data.wifiSignal}')),
              ExpansionTile(
                title: Text('树木阀门延迟：${data.valve1Delay}'),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: TextFormField(
                      initialValue: data.valve1Delay.toString(),
                      onFieldSubmitted: (value) {
                        BlocProvider.of<DeviceEditBloc>(context).add(
                          DeviceSeted(
                            deviceId: device.id,
                            key: 'valve1_delay',
                            value: value,
                            valueType: 'INTEGER',
                          ),
                        );
                        showInfoSnackBar('正在设置...');
                      },
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  )
                ],
              ),
              ExpansionTile(
                title: Text('菜地阀门延迟：${data.valve2Delay}'),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: TextFormField(
                      initialValue: data.valve2Delay.toString(),
                      onFieldSubmitted: (value) {
                        BlocProvider.of<DeviceEditBloc>(context).add(
                          DeviceSeted(
                            deviceId: device.id,
                            key: 'valve2_delay',
                            value: value,
                            valueType: 'INTEGER',
                          ),
                        );
                        showInfoSnackBar('正在设置...');
                      },
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  )
                ],
              ),
              ExpansionTile(
                title: Text('后花园阀门延迟：${data.valve3Delay}'),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: TextFormField(
                      initialValue: data.valve3Delay.toString(),
                      onFieldSubmitted: (value) {
                        BlocProvider.of<DeviceEditBloc>(context).add(
                          DeviceSeted(
                            deviceId: device.id,
                            key: 'valve3_delay',
                            value: value,
                            valueType: 'INTEGER',
                          ),
                        );
                        showInfoSnackBar('正在设置...');
                      },
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  )
                ],
              ),
              ExpansionTile(
                title: Text('泵延迟：${data.pumpDelay}'),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: TextFormField(
                      initialValue: data.pumpDelay.toString(),
                      onFieldSubmitted: (value) {
                        BlocProvider.of<DeviceEditBloc>(context).add(
                          DeviceSeted(
                            deviceId: device.id,
                            key: 'pump_delay',
                            value: value,
                            valueType: 'INTEGER',
                          ),
                        );
                        showInfoSnackBar('正在设置...');
                      },
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  )
                ],
              ),
            ]),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
