import 'package:flutter/material.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/iot/view/widgets/device_card.dart';
import 'package:smarthome/widgets/home_page.dart';

class IotHomePage extends Page {
  const IotHomePage()
      : super(
          key: const ValueKey('iot'),
          name: '/iot',
        );

  @override
  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
      settings: this,
      pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) =>
          FadeTransition(
        opacity: animation,
        child: const IotHomeScreen(),
      ),
    );
  }
}

class IotHomeScreen extends StatelessWidget {
  const IotHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MyHomePage(
      activeTab: AppTab.iot,
      slivers: [
        SliverToBoxAdapter(child: DeviceCard(deviceId: 'RGV2aWNlOjE=')),
        SliverToBoxAdapter(child: DeviceCard(deviceId: 'RGV2aWNlOjE=')),
      ],
    );
  }
}
