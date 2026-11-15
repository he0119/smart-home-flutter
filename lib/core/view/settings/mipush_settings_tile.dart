import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/core/router/app_router.dart';
import 'package:smarthome/widgets/settings/settings.dart';
import 'package:smarthome/widgets/app_preview.dart';
import 'package:smarthome/widgets/preview_frame.dart';

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
      leading: Icons.notifications_outlined,
      title: '小米推送',
      subtitle: status,
      subtitleMaxLines: 2,
      onPressed: (context) {
        context.push(AppRoutes.miPushSettings);
      },
    );
  }
}

/// 开发时在 IDE 里直接看效果，不依赖后端数据。
@AppPreview(
  name: 'MiPushSettingsTile 已注册',
  group: previewGroupSettings,
  size: Size(400, 120),
)
Widget miPushSettingsTilePreview() => PreviewFrame(
  width: 400,
  padding: EdgeInsets.zero,
  child: PreviewProviders(
    settings: previewSettings(miPushRegId: 'preview-reg-id'),
    child: const MiPushSettingsTile(),
  ),
);
