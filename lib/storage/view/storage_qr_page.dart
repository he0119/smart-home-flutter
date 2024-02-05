import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:smarthome/storage/model/models.dart';
import 'package:smarthome/storage/view/widgets/share_icon_button.dart';

class StorageQrPage extends StatelessWidget {
  final Storage storage;

  const StorageQrPage({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('二维码'),
        actions: [
          ShareQrIconButton(name: storage.name, data: storage.id),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: storage.id,
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
