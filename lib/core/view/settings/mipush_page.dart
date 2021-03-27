import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthome/core/bloc/blocs.dart';
import 'package:smarthome/core/model/models.dart';

class MiPushPage extends StatelessWidget {
  const MiPushPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late MiPush miPush;
    return BlocBuilder<PushBloc, PushState>(builder: (context, state) {
      if (state is PushInProgress) {
        miPush = MiPush(regId: '正在获取数据');
      }
      if (state is PushSuccess) {
        miPush = state.miPush;
      }
      if (state is PushError) {
        miPush = MiPush(regId: state.message);
      }
      return BlocBuilder<AppPreferencesBloc, AppPreferencesState>(
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            title: Text('小米推送'),
            actions: [
              Tooltip(
                message: '同步',
                child: IconButton(
                    icon: Icon(Icons.sync),
                    onPressed: () {
                      BlocProvider.of<AppPreferencesBloc>(context)
                          .add(MiPushRegIdChanged(miPushRegId: '正在同步注册标识符'));
                      BlocProvider.of<PushBloc>(context).add(PushStarted());
                    }),
              ),
            ],
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
