import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:smarthome/app/dimens.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/core/router/app_router.dart';
import 'package:smarthome/storage/model/models.dart';
import 'package:smarthome/storage/view/widgets/share_icon_button.dart';
import 'package:smarthome/widgets/home_page.dart';
import 'package:smarthome/widgets/list_rows.dart';

class StorageQRPage extends ConsumerWidget {
  final Storage storage;

  const StorageQRPage({super.key, required this.storage});

  String getStorageUrl(String? apiUrl, String storageId) {
    final url = Uri.parse(apiUrl ?? '');
    final path = AppRoutes.storageDetailPath(storageId);
    return '${url.scheme}://${url.host}$path';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final url = getStorageUrl(settings.apiUrl, storage.id);
    final theme = Theme.of(context);
    // 小屏和横屏都要放得下，二维码不要写死 300
    final qrSize = math.min(300.0, MediaQuery.sizeOf(context).width - 96);

    return MySliverScaffold(
      appBarSize: AppBarSize.normal,
      title: const Text('位置二维码'),
      actions: [ShareQrIconButton(name: storage.name, data: url)],
      sliver: SliverFillRemaining(
        hasScrollBody: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: <Widget>[
              Semantics(
                image: true,
                label: '位置「${storage.name}」的二维码',
                child: QrImageView(
                  data: url,
                  size: qrSize,
                  version: QrVersions.auto,
                  gapless: true,
                  backgroundColor: theme.colorScheme.surface,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              InfoRow(label: '位置名称', value: Text(storage.name), onTap: null),
              const ContentDivider(indent: 0),
              InfoRow(label: '位置 ID', value: Text(storage.id)),
              const ListBottomPadding(),
            ],
          ),
        ),
      ),
    );
  }
}
