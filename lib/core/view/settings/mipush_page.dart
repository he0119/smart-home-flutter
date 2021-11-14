import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthome/core/bloc/blocs.dart';

class MiPushPage extends StatelessWidget {
  const MiPushPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PushBloc, PushState>(
      builder: (context, state) {
        String status = '未知';
        String? localRegId;
        String? serverRegId;
        if (state is PushInProgress) {
          status = '注册中';
        }
        if (state is PushSuccess) {
          localRegId = state.local;
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
                    // 重新初始化小米推送以同步本地与服务器的注册状态
                    context.read<PushBloc>().add(PushStarted());
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
                subtitle: Text(serverRegId ?? ''),
              ),
            ],
          ),
        );
      },
    );
  }
}
