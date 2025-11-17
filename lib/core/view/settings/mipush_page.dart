import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/core/providers/push_provider.dart';
import 'package:smarthome/core/providers/settings_provider.dart';
import 'package:smarthome/widgets/home_page.dart';

class MiPushPage extends ConsumerWidget {
  const MiPushPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pushInfo = ref.watch(pushProvider);
    final settings = ref.watch(settingsProvider);
    final localRegId = settings.miPushRegId;
    final serverRegId = pushInfo.serverRegId;

    String status = '未知';
    if (pushInfo.isLoading) {
      status = '注册中';
    } else if (pushInfo.errorMessage != null) {
      status = pushInfo.errorMessage!;
    } else if (localRegId != null) {
      status = '已注册';
    }

    return MySliverScaffold(
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
                ref.read(pushProvider.notifier).refreshPush(local);
              } else {
                ref.read(pushProvider.notifier).startPush();
              }
            },
          ),
        ),
      ],
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          ListTile(title: const Text('状态'), subtitle: Text(status)),
          ListTile(
            title: const Text('注册识别码（本地）'),
            subtitle: Text(localRegId ?? ''),
          ),
          ListTile(
            title: const Text('注册识别码（服务器）'),
            subtitle: Text(serverRegId ?? '单击同步按钮获取并同步服务器数据'),
          ),
        ]),
      ),
    );
  }
}
