import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/models/app_tab.dart';
import 'package:smart_home/widgets/tab_selector.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class IotHomePage extends StatelessWidget {
  const IotHomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _IotHomeBody(),
      bottomNavigationBar: TabSelector(
        activeTab: AppTab.iot,
        onTabSelected: (tab) =>
            BlocProvider.of<TabBloc>(context).add(UpdateTab(tab)),
      ),
    );
  }
}

class _IotHomeBody extends StatelessWidget {
  const _IotHomeBody({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const String url = 'https://iot.hehome.xyz';
    return !kIsWeb
        ? WebView(
            key: UniqueKey(),
            initialUrl: url,
            javascriptMode: JavascriptMode.unrestricted,
          )
        : Center(
            child: RaisedButton(
              onPressed: () => _launchUrl(url),
              child: Text('IOT'),
            ),
          );
  }
}

Future _launchUrl(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
