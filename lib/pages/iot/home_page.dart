import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/core/blocs.dart';
import 'package:smart_home/blocs/iot/blocs.dart';
import 'package:smart_home/models/app_tab.dart';
import 'package:smart_home/models/iot.dart';
import 'package:smart_home/pages/settings/iot/settings_page.dart';
import 'package:smart_home/repositories/iot_repository.dart';
import 'package:smart_home/routers/delegate.dart';
import 'package:smart_home/widgets/center_loading_indicator.dart';
import 'package:smart_home/widgets/error_message_button.dart';
import 'package:smart_home/widgets/home_page.dart';
import 'package:smart_home/utils/show_snack_bar.dart';
import 'package:smart_home/utils/date_format_extension.dart';

class IotHomePage extends StatelessWidget {
  const IotHomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppPreferencesBloc, AppPreferencesState>(
      builder: (context, state) {
        return MultiBlocProvider(
          key: ValueKey(state.refreshInterval),
          providers: [
            BlocProvider<DeviceDataBloc>(
              // 因为只有一个设备就先写死
              create: (context) => DeviceDataBloc(
                iotRepository: RepositoryProvider.of<IotRepository>(context),
                deviceId: '1',
              )..add(DeviceDataStarted(state.refreshInterval)),
            ),
            BlocProvider<DeviceEditBloc>(
              create: (context) => DeviceEditBloc(
                iotRepository: RepositoryProvider.of<IotRepository>(context),
              ),
            ),
          ],
          child: MyHomePage(
            activeTab: AppTab.iot,
            body: _IotHomeBody(),
            actions: <Widget>[
              Tooltip(
                message: '设置',
                child: IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () {
                    MyRouterDelegate.of(context).push(IotSettingsPage());
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _IotHomeBody extends StatelessWidget {
  const _IotHomeBody({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceDataBloc, DeviceDataState>(
      builder: (context, state) {
        if (state is DeviceDataSuccess) {
          Device device = state.autowateringData.device;
          AutowateringData data = state.autowateringData;
          return BlocBuilder<AppPreferencesBloc, AppPreferencesState>(
            builder: (context, state) => ListView(
              children: [
                ListTile(
                  title: Text(device.name),
                  subtitle: Text(data.time.toLocalStr()),
                  trailing: Text(device.isOnline ? '在线' : '离线'),
                ),
                ListTile(title: Text('温度：' + data.temperature.toString())),
                ListTile(title: Text('湿度：' + data.humidity.toString())),
                SwitchListTile(
                  title: Text('树木'),
                  value: data.valve1,
                  onChanged: (value) {
                    BlocProvider.of<DeviceEditBloc>(context).add(DeviceSeted(
                      deviceId: device.id,
                      key: 'valve1',
                      value: value.toString(),
                      valueType: 'bool',
                    ));
                    showInfoSnackBar(value ? '正在开启...' : '正在关闭...');
                  },
                ),
                SwitchListTile(
                  title: Text('菜地'),
                  value: data.valve2,
                  onChanged: (value) {
                    BlocProvider.of<DeviceEditBloc>(context).add(DeviceSeted(
                      deviceId: device.id,
                      key: 'valve2',
                      value: value.toString(),
                      valueType: 'bool',
                    ));
                    showInfoSnackBar(value ? '正在开启...' : '正在关闭...');
                  },
                ),
                SwitchListTile(
                  title: Text('后花园'),
                  value: data.valve3,
                  onChanged: (value) {
                    BlocProvider.of<DeviceEditBloc>(context).add(DeviceSeted(
                      deviceId: device.id,
                      key: 'valve3',
                      value: value.toString(),
                      valueType: 'bool',
                    ));
                    showInfoSnackBar(value ? '正在开启...' : '正在关闭...');
                  },
                ),
                SwitchListTile(
                  title: Text('水泵'),
                  value: data.pump,
                  onChanged: (value) {
                    BlocProvider.of<DeviceEditBloc>(context).add(DeviceSeted(
                      deviceId: device.id,
                      key: 'pump',
                      value: value.toString(),
                      valueType: 'bool',
                    ));
                    showInfoSnackBar(value ? '正在开启...' : '正在关闭...');
                  },
                ),
                ListTile(title: Text('无线信号强度：' + data.wifiSignal.toString())),
                ExpansionTile(
                  title: Text('树木阀门延迟：' + data.valve1Delay.toString()),
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
                              valueType: 'int',
                            ),
                          );
                          showInfoSnackBar('正在设置...');
                        },
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                    )
                  ],
                ),
                ExpansionTile(
                  title: Text('菜地阀门延迟：' + data.valve2Delay.toString()),
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
                              valueType: 'int',
                            ),
                          );
                          showInfoSnackBar('正在设置...');
                        },
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                    )
                  ],
                ),
                ExpansionTile(
                  title: Text('后花园阀门延迟：' + data.valve3Delay.toString()),
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
                              valueType: 'int',
                            ),
                          );
                          showInfoSnackBar('正在设置...');
                        },
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                    )
                  ],
                ),
                ExpansionTile(
                  title: Text('泵延迟：' + data.pumpDelay.toString()),
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
                              valueType: 'int',
                            ),
                          );
                          showInfoSnackBar('正在设置...');
                        },
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          );
        }
        if (state is DeviceDataFailure) {
          return ErrorMessageButton(
            onPressed: () {
              final appPreference = context.read<AppPreferencesBloc>().state;
              BlocProvider.of<DeviceDataBloc>(context)
                  .add(DeviceDataStarted(appPreference.refreshInterval));
            },
            message: state.message,
          );
        }
        return CenterLoadingIndicator();
      },
    );
  }
}
