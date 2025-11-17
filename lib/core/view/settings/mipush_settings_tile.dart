import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/core/providers/push_provider.dart';
import 'package:smarthome/core/providers/settings_provider.dart';
import 'package:smarthome/core/view/settings/mipush_page.dart';
import 'package:smarthome/widgets/settings/settings.dart';

class MiPushSettingsTile extends ConsumerWidget {
  const MiPushSettingsTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pushInfo = ref.watch(pushProvider);
    final settings = ref.watch(settingsProvider);

    var status = '未知';
    if (pushInfo.isLoading) {
      status = '注册中';
    } else if (pushInfo.errorMessage != null) {
      status = pushInfo.errorMessage!;
    } else if (settings.miPushRegId != null) {
      status = '已注册';
    }
    return SettingsTile(
      title: '小米推送',
      subtitle: status,
      onPressed: (context) {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const MiPushPage()));
      },
    );
  }
}
