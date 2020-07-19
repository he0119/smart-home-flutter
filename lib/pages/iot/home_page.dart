import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/blocs/iot/blocs.dart';
import 'package:smart_home/models/app_tab.dart';
import 'package:smart_home/models/grobal_keys.dart';
import 'package:smart_home/models/iot.dart';
import 'package:smart_home/pages/loading_page.dart';
import 'package:smart_home/repositories/iot_repository.dart';
import 'package:smart_home/widgets/show_snack_bar.dart';
import 'package:smart_home/widgets/tab_selector.dart';
import 'package:smart_home/utils/date_format_extension.dart';

class IotHomePage extends StatelessWidget {
  const IotHomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppPreferencesBloc, AppPreferencesState>(
      builder: (context, state) {
        return MultiBlocProvider(
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
          child: Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              title: Text('IOT'),
            ),
            body: _IotHomeBody(),
            bottomNavigationBar: TabSelector(
              activeTab: AppTab.iot,
              onTabSelected: (tab) =>
                  BlocProvider.of<TabBloc>(context).add(TabChanged(tab)),
            ),
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
          return Column(
            children: [
              ListTile(
                title: Text(device.name),
                subtitle: Text(data.time.toLocaljmsStr()),
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
                  showInfoSnackBar(context, value ? '正在开启...' : '正在关闭...');
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
                  showInfoSnackBar(context, value ? '正在开启...' : '正在关闭...');
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
                  showInfoSnackBar(context, value ? '正在开启...' : '正在关闭...');
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
                  showInfoSnackBar(context, value ? '正在开启...' : '正在关闭...');
                },
              ),
              ListTile(title: Text('无线信号强度：' + data.wifiSignal.toString())),
            ],
          );
        }
        return LoadingPage();
      },
    );
  }
}
