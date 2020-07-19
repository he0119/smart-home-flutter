import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/blocs/iot/device_data/device_data_bloc.dart';
import 'package:smart_home/models/app_tab.dart';
import 'package:smart_home/models/grobal_keys.dart';
import 'package:smart_home/models/iot.dart';
import 'package:smart_home/pages/loading_page.dart';
import 'package:smart_home/repositories/iot_repository.dart';
import 'package:smart_home/widgets/tab_selector.dart';
import 'package:smart_home/utils/date_format_extension.dart';

class IotHomePage extends StatelessWidget {
  const IotHomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppPreferencesBloc, AppPreferencesState>(
      builder: (context, state) => BlocProvider<DeviceDataBloc>(
        create: (context) => DeviceDataBloc(
          iotRepository: RepositoryProvider.of<IotRepository>(context),
        )..add(DeviceDataStarted(state.refreshInterval)),
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
      ),
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
              Text(device.name),
              Text(device.isOnline ? '在线' : '离线'),
              Text(data.time.toLocaljmsStr()),
            ],
          );
        }
        return LoadingPage();
      },
    );
  }
}
