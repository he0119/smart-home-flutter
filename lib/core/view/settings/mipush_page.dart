import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/widgets/home_page.dart';
import 'package:smarthome/widgets/list_rows.dart';

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
      appBarSize: AppBarSize.normal,
      title: const Text('小米推送'),
      actions: [
        IconButton(
          tooltip: '重新同步注册信息',
          icon: const Icon(Icons.sync),
          // 注册中不让连点，避免重复请求
          onPressed: pushInfo.isLoading
              ? null
              : () {
                  final local = localRegId;
                  if (local != null) {
                    ref.read(pushProvider.notifier).refreshPush(local);
                  } else {
                    ref.read(pushProvider.notifier).startPush();
                  }
                },
        ),
      ],
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          const SectionHeader(
            title: '注册状态',
            padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
          ),
          InfoRow(
            label: '状态',
            value: Text(status, style: Theme.of(context).textTheme.bodyLarge),
          ),
          const ContentDivider(indent: 16),
          InfoRow(
            label: '注册识别码（本地）',
            value: Text(
              localRegId ?? '尚未注册',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const ContentDivider(indent: 16),
          InfoRow(
            label: '注册识别码（服务器）',
            value: Text(
              serverRegId ?? '点右上角按钮同步获取',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const ListBottomPadding(height: 24),
        ]),
      ),
    );
  }
}
