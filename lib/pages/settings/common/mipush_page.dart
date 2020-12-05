import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/app_preferences/app_preferences_bloc.dart';
import 'package:smart_home/blocs/push/push_bloc.dart';
import 'package:smart_home/models/push.dart';

class MiPushPage extends StatelessWidget {
  const MiPushPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MiPush miPush;
    return BlocBuilder<PushBloc, PushState>(builder: (context, state) {
      if (state is PushSuccess) {
        miPush = state.miPush;
      }
      return BlocBuilder<AppPreferencesBloc, AppPreferencesState>(
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            title: Text('小米推送'),
          ),
          body: ListView(
            children: [
              ListTile(
                title: Text('注册识别码（本地）'),
                subtitle: Text(state.miPushRegId ?? ''),
              ),
              ListTile(
                title: Text('注册识别码（服务器）'),
                subtitle: Text(miPush.regId ?? '单击获取服务器上数据'),
                onTap: () {
                  BlocProvider.of<PushBloc>(context).add(PushRefreshed());
                },
              ),
            ],
          ),
        ),
      );
    });
  }
}
