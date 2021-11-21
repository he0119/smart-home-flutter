import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthome/core/bloc/blocs.dart';
import 'package:smarthome/app/settings/settings_controller.dart';

class MiPushPage extends StatelessWidget {
  const MiPushPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PushBloc, PushState>(
      builder: (context, state) {
        final localRegId = context
            .select((SettingsController settings) => settings.miPushRegId);
        String? serverRegId;

        String status = '未知';
        if (state is PushInProgress) {
          status = '注册中';
        }
        if (state is PushSuccess) {
          serverRegId = state.server;
          status = '已注册';
        }
        if (state is PushError) {
          status = state.message;
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('小米推送'),
            actions: [
              Tooltip(
                message: '同步',
                child: IconButton(
                  icon: const Icon(Icons.sync),
                  onPressed: () {
                    // 重新同步本地与服务器的注册数据
                    final local = localRegId;
                    if (local != null) {
                      context.read<PushBloc>().add(PushRefreshed(regId: local));
                    } else {
                      context.read<PushBloc>().add(PushStarted());
                    }
                  },
                ),
              ),
            ],
          ),
          body: ListView(
            children: [
              ListTile(
                title: const Text('状态'),
                subtitle: Text(status),
              ),
              ListTile(
                title: const Text('注册识别码（本地）'),
                subtitle: Text(localRegId ?? ''),
              ),
              ListTile(
                title: const Text('注册识别码（服务器）'),
                subtitle: Text(serverRegId ?? '单击同步按钮获取并同步服务器数据'),
              ),
            ],
          ),
        );
      },
    );
  }
}
