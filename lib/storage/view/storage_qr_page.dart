import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:smarthome/core/providers/settings_provider.dart';
import 'package:smarthome/storage/model/models.dart';
import 'package:smarthome/storage/view/widgets/share_icon_button.dart';

class StorageQRPage extends ConsumerWidget {
  final Storage storage;

  const StorageQRPage({super.key, required this.storage});

  String getStorageUrl(String? apiUrl, String storageId) {
    final url = Uri.parse(apiUrl ?? '');
    return '${url.scheme}://${url.host}/storage/$storageId';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('二维码'),
        actions: [
          ShareQrIconButton(
            name: storage.name,
            data: getStorageUrl(settings.apiUrl, storage.id),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: getStorageUrl(settings.apiUrl, storage.id),
              size: 300.0,
              version: QrVersions.auto,
              gapless: true,
            ),
            Text('ID: ${storage.id}'),
            Text('名称: ${storage.name}'),
          ],
        ),
      ),
    );
  }
}
